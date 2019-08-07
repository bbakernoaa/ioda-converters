!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! bufrio_bufr2ioda
!! - contains subroutines to read BUFR files with NCEP bufrlib
!!
!! author: Cory Martin - cory.r.martin@noaa.gov
!! history:  2019-08-05 - original
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
module bufrio_bufr2ioda
  implicit none
  private
  ! public subroutines
  public :: initbufr
  public :: proc_msgtype
  ! public variables
  public :: lunin
  public :: nmsg
  public :: msgtypes, msgcounts, bufrmsgs, msgdates, ntypes
  integer, parameter :: lunin = 13
  integer, parameter :: maxtypes = 20
  integer :: nmsg, ntypes
  character(len=10), allocatable, dimension(:) :: bufrmsgs, msgtypes
  character(len=10), allocatable, dimension(:) :: validvars
  integer, allocatable, dimension(:) :: varcounts
  integer, allocatable, dimension(:) :: msgdates, msgcounts
contains
  subroutine initbufr
    use init_bufr2ioda, only: bufrfile
    implicit none
    ! locally used variables
    integer :: iret, idate, imsg, loc
    integer :: ireadmg, ireadmm, findloc
    integer, dimension(20) :: locs
    character(len=10) :: subset
    !! initialize some vars
    nmsg = 0
    ntypes = 0
    !! open specified bufr file
    !! get number of messages, types, etc.
    call closbf(lunin) ! for good measure
    open(lunin,file=trim(bufrfile),form='unformatted')
    call openbf(lunin,'IN',lunin) ! open file with bufr lib
    call datelen(10) ! we want 4-digit years: YYYYMMDDHH
    ! get number of messages in BUFR file
    do while (ireadmg(lunin,subset,idate) == 0)
      nmsg = nmsg+1
    end do
    ! allocate arrays
    allocate(bufrmsgs(nmsg), msgdates(nmsg))
    allocate(msgtypes(maxtypes), msgcounts(maxtypes))
    write (*,*) "Number of messages to process:", nmsg
    ! loop again and put fields in memory
    call rewnbf(lunin,0)
    do imsg=1,nmsg
      iret = ireadmg(lunin,subset,idate)
      if (iret /= 0) then
        write (*,*) "Fatal Error! Stopping!"
        stop
      end if
      bufrmsgs(imsg) = subset
      msgdates(imsg) = idate
      ! getting different types of messages in file
      if (.not. any(msgtypes==trim(subset))) then
        ntypes = ntypes + 1
        msgtypes(ntypes) = trim(subset)
      end if
    end do
    ! getting number of messages in each subtype 
    do imsg=1,ntypes
      msgcounts(imsg) = count(bufrmsgs==trim(msgtypes(imsg)))
      write(*,*) trim(msgtypes(imsg)), msgcounts(imsg)
    end do
    
  end subroutine initbufr

  subroutine proc_msgtype(msgtype)
    ! top level routine for processing all messages of type 'msgtype'
    use init_bufr2ioda, only: bufrfile
    implicit none
    character(10), intent(in) :: msgtype
    integer :: imsg, iret, idate, nreps, ireps
    integer :: ireadmg, ireadsb, nmsub
    character(len=10) :: subset,fullnemo
    character(len=6) :: nemo
    logical :: iftype
    logical :: readtable
    integer, parameter :: maxvals = 10
    !integer, parameter :: maxvals = 10000
    real(8), dimension(maxvals,1) :: usr
    integer :: ival, i2
    call closbf(lunin) ! for good measure
    open(lunin,file=trim(bufrfile),form='unformatted')
    call openbf(lunin,'IN',lunin) ! open file with bufr lib
    call datelen(10) ! we want 4-digit years: YYYYMMDDHH
    readtable = .true.
    do imsg=1,nmsg
      iret = ireadmg(lunin, subset, idate)
      if (trim(bufrmsgs(imsg)) == trim(msgtype)) then
        nreps = nmsub(lunin)
        !fullnemo = bufrmsgs(imsg)
        !nemo = fullnemo
        !if (fullnemo(1:2) == "NC") nemo = fullnemo(3:10)
        do ireps=1, nreps
          iret = ireadsb(lunin)
          if (ireps == 1 .and. readtable) then
             ! scan BUFR subset for information
             call ufdump(lunin, 50)
             close(50)
             open(50)
             call read_valid_vars
             readtable = .false.
          end if
          !stop
          !call ufbint(lunin, usr, 10, 1, iret, "YEAR MNTH DAYS HOUR")
          !call ufbseq(lunin, usr, maxvals, 1, iret, nemo)
          !print *, usr
          !do ival=1,10000
          !  if (usr(ival,1) < 1e6) print *, usr(ival,1)
          !end do
        end do
      end if
      print *, imsg
    end do
  end subroutine proc_msgtype

  subroutine read_valid_vars
    ! use the temporary output of ufdump from NCEP BUFR lib to figure out
    ! the list of mnemonics that can be read from this file
    ! alternatively this can be modified to read a file with only a subset
    ! of mnemonics
    implicit none
    character(10) :: code, vname, vname2
    character(10), allocatable, dimension(:) :: vnames
    integer :: i, nlines, io, nvars
    integer, parameter :: ifile=50
    nlines = 0
    do
      read(ifile, *, iostat=io)
      if (io /= 0) exit
      nlines = nlines + 1
    end do
    rewind(ifile)
    allocate(validvars(nlines-6),varcounts(nlines-6),vnames(nlines-6))
    nvars = 0
    read(ifile, *)
    read(ifile, *)
    read(ifile, *)
    do i=1,nlines-6 ! assumes first 3 should be thrown out
      read(ifile, *) code, vname, vname2
      if (code(1:4) /= "++++" .and. vname2(1:5) /= "REPLI" .and..not. any(validvars==vname)) then
        nvars = nvars+1
        validvars(nvars) = vname
        varcounts(nvars) = 1
      end if
      vnames(i) = vname
    end do
    do i=1, nvars
      varcounts(i) = count(vnames==validvars(i))
      print *, validvars(i), varcounts(i)
    end do
  end subroutine read_valid_vars

end module bufrio_bufr2ioda
