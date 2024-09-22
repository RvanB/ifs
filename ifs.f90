program ifs
  use omp_lib
  implicit none

  ! ---------- VARIABLES & CONSTANTS ----------
  ! Constants
  real, parameter :: pi = 3.14159

  ! Parameters
  real, parameter :: zoom=1500
  integer, parameter :: W=2000, H=2000
  integer(4), parameter :: ITERATIONS=10**8

  ! Variables
  real, dimension(3, H, W) :: image = 0
  real :: theta
  integer :: file_unit, i
  real :: color(3)

  real :: rl
  real :: imag

  ! Thread private variables
  complex :: point
  real :: r
  real, allocatable :: local_image(:,:,:)

  ! Timing variables
  integer :: start_clock, end_clock, clock_rate
  real :: elapsed_time

  ! Get count rate so we can calculate seconds
  call system_clock(count_rate=clock_rate)

  ! Start clock
  call system_clock(start_clock)

  ! ---------- MAIN SECTION ----------

  ! Set color
  call random_number(color)
  color = color / sqrt(sum(color**2))
  

  ! Parallelize the main loop with OpenMP
  !$omp parallel private(point, r, local_image) shared(color, image)

  ! Allocate image on heap (rather than stack)
  allocate(local_image(3, H, W))
  local_image = 0.0

  ! Create a random point in unit circle
  call random_number(rl)
  call random_number(imag)
  point = cmplx(rl, imag)
  point = point * 2 - 1

  !$omp do schedule(static)
  do i = 1, ITERATIONS

     point = tan(ring(point, 5, 1., 0.7))**2
          
     call draw_point(point, color, image)
  end do
  !$omp end do

  !$omp critical
  image = image + local_image
  !$omp end critical

  !$omp end parallel

  print *, "Finished calculations. Writing image..."

  call write_image(image=image, path="image.ppm", gain=2.5)

  ! End clock
  call system_clock(end_clock)
  elapsed_time = real(end_clock - start_clock) / real(clock_rate)

  print *, "Elapsed time: ", elapsed_time, " seconds"


contains

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

  subroutine draw_point(point, color, image)
    complex, intent(in) :: point
    real, intent(in) :: color(3)
    real, intent(inout) :: image(3, H, W)
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
  end subroutine write_image

end program ifs
