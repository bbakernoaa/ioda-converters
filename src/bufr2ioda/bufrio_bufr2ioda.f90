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
  ! public variables
  public :: lunin
  public :: nmsg
  public :: msgtypes, msgcounts, bufrmsgs, msgdates
  integer, parameter :: lunin = 13
  integer, parameter :: maxtypes = 20
  integer :: nmsg
  character(len=10), allocatable, dimension(:) :: bufrmsgs, msgtypes
  integer, allocatable, dimension(:) :: msgdates, msgcounts
contains
  subroutine initbufr
    use init_bufr2ioda, only: bufrfile
    implicit none
    ! locally used variables
    integer :: iret, idate, imsg, loc, ntypes
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
    end do
    
  end subroutine initbufr
end module bufrio_bufr2ioda
