!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! init_bufr2ioda
!! - contains initialization subroutines
!!     init       - reads in command line arguments, etc.
!!
!! author: Cory Martin - cory.r.martin@noaa.gov
!! history:  2019-08-05 - original
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
module init_bufr2ioda
  implicit none
  private
  ! public subroutines
  public :: init
  ! public variables
  public :: bufrfile, outdir
  character(len=255) :: bufrfile, outdir
contains
  subroutine init
    implicit none
    ! local variable definitions
    integer :: nargs
    logical :: exist_in
    ! get command line arguments
    nargs = command_argument_count()
    if (nargs /= 2) then
      write(*,*) "usage: bufr2ioda /path/to/bufrfile /path/to/output/"
      write(*,*) "Not enough arguments... Fatal Error!"
      stop
    end if
    call get_command_argument(1, bufrfile)
    call get_command_argument(2, outdir)
    ! fail if input bufr file doesn't exist
    inquire(file=bufrfile, exist=exist_in)
    if (.not. exist_in) then
      write(*,*) "Specified BUFR file does not exist. Fatal Error!"
      stop
    end if
  end subroutine init
end module init_bufr2ioda
