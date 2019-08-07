!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! bufr2ioda
!!  - utility to read BUFR formatted observations and output
!!    them to a JEDI IODA compatible format
!!
!! author: Cory Martin - cory.r.martin@noaa.gov
!! history: 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
program bufr2ioda
  use init_bufr2ioda, only: init
  use bufrio_bufr2ioda, only: initbufr, proc_msgtype
  use bufrio_bufr2ioda, only: msgtypes, ntypes
  implicit none
  ! local variables
  integer :: imsg, itype
  character(255) :: outnametmp
  character(6) :: tmptype
  !! top level driver program, calls subroutines from modules
  call init ! initialize program
  call initbufr ! open bufr file
  do itype=1,ntypes
    ! placeholder set up output files
    tmptype = msgtypes(itype)
    outnametmp = tmptype//"_data.dat"
    open(100+itype, file=trim(outnametmp), form='unformatted')
    ! end placeholder
    write(*,*) "Processing message type: "//trim(msgtypes(itype))
    call proc_msgtype(trim(msgtypes(itype)))
  end do
  

end program bufr2ioda

