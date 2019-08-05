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
  use bufrio_bufr2ioda, only: initbufr
  implicit none
  !! top level driver program, calls subroutines from modules
  call init ! initialize program
  call initbufr ! open bufr file
  

end program bufr2ioda

