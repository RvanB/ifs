module rendering
  use, intrinsic :: iso_c_binding
  implicit none
  
  real, parameter :: zoom=1500
  integer, parameter :: WIDTH=2000, HEIGHT=2000
  ! real, pointer :: image(:,:,:)
  real, target :: image(3, HEIGHT, WIDTH)
  integer :: file_unit, i

contains
  subroutine stack_image(other_image)
    real, intent(in) :: other_image(3, HEIGHT, WIDTH)
    image = image + other_image
  end subroutine stack_image
  
  subroutine draw_point(point, color, image)
    complex, intent(in) :: point
    real, intent(in) :: color(3)
    real, intent(inout) :: image(3, HEIGHT, WIDTH)
    integer :: i, j

    i = int(real(point, 8) * zoom + HEIGHT/2)
    j = int(aimag(point) * zoom + WIDTH/2)

    if (i > 0 .and. i < HEIGHT .and. j > 0 .and. j < WIDTH) then
       image(:, i, j) = image(:, i, j) + color
    endif

  end subroutine draw_point

  subroutine write_image(gain)
    use c_interface
    real, intent(in) :: gain

    image = image ** (1/2.2) ! Gamma correction
    image = (image - minval(image)) / (maxval(image) - minval(image)) * gain
    
    ! Call C function
    call c_function(c_loc(image), HEIGHT, WIDTH)
  end subroutine write_image
  
end module rendering

! Fortran module to define the interface
module c_interface
    use, intrinsic :: iso_c_binding
    implicit none

    interface
        subroutine c_function(img, height, width) bind(c, name="c_function")
          use iso_c_binding
          integer(c_int) :: height, width
          type(c_ptr), value :: img     
        end subroutine c_function
    end interface
end module c_interface
