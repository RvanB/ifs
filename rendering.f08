module rendering
  use, intrinsic :: iso_c_binding
  implicit none
  
  real, allocatable, target :: image(:,:,:)
  integer :: file_unit, i

contains
  subroutine initialize_image(height, width)
    integer, intent(in) :: width, height
    allocate(image(3, height, width))
    image = 0
  end subroutine initialize_image
  
  subroutine stack_image(other_image)
    real, intent(in) :: other_image(:,:,:)
    image = image + other_image
  end subroutine stack_image
  
  subroutine draw_point(point, color, image)
    complex, intent(in) :: point
    real, intent(in) :: color(3)
    real, intent(inout) :: image(:,:,:)
    integer :: x, y

    ! Get width and height from image shape
    integer :: height, width
    height = size(image, 2)
    width = size(image, 3)

    ! i = int(real(point, 8) * zoom + height/2)
    ! j = int(aimag(point) * zoom + width/2)

    x = int(real(point))
    y = int(aimag(point))

    if (y > 0 .and. y < height .and. x > 0 .and. x < width) then
       image(:, y, x) = image(:, y, x) + color
    endif

  end subroutine draw_point

  subroutine write_image(gain)
    use c_interface
    real, intent(in) :: gain

    integer :: height, width
    ! Get width and height from image shape
    height = size(image, 2)
    width = size(image, 3)

    image = image ** (1/2.2) ! Gamma correction
    image = (image - minval(image)) / (maxval(image) - minval(image)) * gain

    
    ! Call C function
    call c_function(c_loc(image), height, width)
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
