program ifs
  use omp_lib
  implicit none
  ! Constants
  real, parameter :: pi = 3.14159

  ! Parameters
  real, parameter :: zoom=3400
  integer, parameter :: W=5000, H=5000
  integer, parameter :: ITERATIONS=10**8

  ! Variables
  real, dimension(3, H, W) :: image = 0
  real :: theta
  integer :: file_unit, i
  real :: color(3)

  complex :: point, temp
  real :: rl
  real :: imag

  ! Thread private variables
  ! integer :: thread_id
  real :: r
  real :: x, y

  call random_number(color)
  
  ! Parallelize the main loop with OpenMP
  !$omp parallel private(point, r) shared(color, image)
  call random_seed()
  

  ! Randomize real and imaginary components of point
  call random_number(rl)
  call random_number(imag)
  point = cmplx(rl, imag)
  
  point = point * 2 - 1

  !$omp do schedule(dynamic)
  do i = 1, ITERATIONS

     point = ring(point, 5, 1., 0.5)**2

     ! call random_number(temp)
     
     !$omp critical
     call draw_point(point, color)
     !$omp end critical
     
  end do
  !$omp end do
  !$omp end parallel

  print *, "Finished calculations. Writing image..."
  
  call write_image(image=image, path="image.ppm", gain=1.0)
contains
  
  function mult_comp(point) result(new_point)
    complex, intent(in) :: point
    complex :: new_point

    real :: x, y

    x = real(point)
    y = aimag(point)

    new_point = cmplx(x * y, x * y)
  end function mult_comp
    
  function sin_xy(point) result(new_point)
    complex, intent(in) :: point
    complex :: new_point
    real :: x, y

    x = real(point)
    y = aimag(point)

    new_point = cmplx(sin(x * y), x * y)
  end function sin_xy
  
  function cos_xy(point) result(new_point)
    complex, intent(in) :: point
    complex :: new_point
    real :: x, y

    x = real(point)
    y = aimag(point)

    new_point = cmplx(cos(x * y), cos(x * y))
  end function cos_xy

  function ring(point, n, radius, ratio) result(new_point)
    complex, intent(in) :: point
    integer, intent(in) :: n
    real, intent(in) :: radius
    real, intent(in) :: ratio
    
    complex :: target_point
    complex :: new_point

    real :: r, theta
    integer :: i

    call random_number(r)
    i = int(r * n)
    theta = 2 * PI / n * i

    target_point = cmplx(cos(theta) * radius, sin(theta) * radius)
    
    new_point = (point + target_point) * ratio
  end function ring

subroutine draw_point(point, color)
    complex, intent(in) :: point
    real, intent(in) :: color(3)
    real :: x, y
    integer :: i, j

    i = int(real(point, 8) * zoom + H/2)
    j = int(aimag(point) * zoom + W/2)

    if (i > 0 .and. i < H .and. j > 0 .and. j < W) then
        image(:, i, j) = image(:, i, j) + color
    endif

end subroutine draw_point
    
  subroutine write_image(image, path, gain)
    real, intent(inout) :: image(3, H, W)
    real, intent(in) :: gain
    character(len=*), intent(in) :: path
    integer :: file_unit, x, y
    real :: r, g, b

    open(NEWUNIT=file_unit, file=path, status='replace', form='formatted')

    write(file_unit, '(A)') 'P3'
    write(file_unit, '(I4)') W
    write(file_unit, '(I4)') H
    write(file_unit, '(A)') '255' ! Max value

    image = image ** (1/2.2) ! Gamma correction
    
    image = (image - minval(image)) / (maxval(image) - minval(image)) * gain
    
    do y = 1, H
       do x = 1, W
          
          r = min(255.0, image(1, y, x) * 255.0)
          g = min(255.0, image(2, y, x) * 255.0)
          b = min(255.0, image(3, y, x) * 255.0)
          
          write(file_unit, '(I3, 1X, I3, 1X, I3, 1X)', advance='no') int(r), int(g), int(b)
       end do
    end do
    
    close(file_unit)
    Print *, path
  end subroutine write_image

end program ifs
