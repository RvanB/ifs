program ifs
  use omp_lib
  use functions
  use rendering
  implicit none

  ! ---------- SETTINGS ----------
  integer, parameter :: ITERATIONS=10**8
  integer, parameter :: WIDTH = 3440*2
  integer, parameter :: HEIGHT = 1440*2
  real, parameter :: GAIN = 6
  real, parameter :: ZOOM = 1500
  character(len=*), parameter :: FILENAME = "test.jpg"

  ! ---------- VARIABLES ----------
  real :: color(3)
  complex :: point
  real :: r
  real, allocatable :: local_image(:,:,:)

  ! ---------- DEFINE FUNCTIONS ----------
  complex :: f, g
  f(point) = tan(ring(point, n=6, radius=1.5, ratio=0.5) * cmplx(0, 1))
  g(point) = point * normalize(cmplx(2, 1))

  ! ---------- MAIN SECTION ----------
  ! Create WxH image
  call initialize_image(HEIGHT, WIDTH)

  ! Parallelize the main loop with OpenMP
  !$omp parallel private(point, r, local_image) shared(color, image)

  ! Allocate image on heap (rather than stack)
  allocate(local_image(3, HEIGHT, WIDTH))
  local_image = 0.0

  ! Create a random point in unit circle
  point = unit_rand()
  point = point * 2 - 1
  
  !$omp do schedule(static)
  do i = 1, ITERATIONS
     
     call random_number(r)
     if (r < 0.5) then
        point = g(f(point))
        color = [0.5, 0.4, .1]
     else
        point = f(g(point))
        call random_number(color)
        color = [0.1, 0.2, 0.4]
     end if
     ! point = f(point)

     ! point = ring(point, 5, 1., 0.5)
          
     call draw_point(point * zoom + cmplx(WIDTH / 2, HEIGHT / 2), color, local_image)
  end do
  !$omp end do

  !$omp critical
  call stack_image(local_image)
  !$omp end critical
  
  !$omp end parallel

  call write_image(gain=GAIN, filename=FILENAME)

end program ifs
