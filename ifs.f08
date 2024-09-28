program ifs
  use omp_lib
  use functions
  use rendering
  implicit none

  ! ---------- SETTINGS ----------
  integer, parameter :: ITERATIONS=10**8
  integer, parameter :: WIDTH = 2000
  integer, parameter :: HEIGHT = 2000
  real, parameter :: GAIN = 2
  real, parameter :: ZOOM = 4000
  character(len=*), parameter :: FILENAME = "output.png"

  ! ---------- VARIABLES ----------
  real :: color(3)
  complex :: point
  real :: r
  real, allocatable :: local_image(:,:,:)

  complex :: ORIGIN = 0

  ! ---------- DEFINE FUNCTIONS ----------
  complex :: f, g, h
  ! g(point) = ring(point, n=4, radius=.8, ratio=0.5)
  f(point) = rotate(ring(point, n=2, radius=0.2 + abs(0.5 * sin(4 * angle(point))), ratio=0.3), theta=magnitude(point), about=point*0.3)

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

     color = [0.1, 0.35, 0.5]
     
     call random_number(r)
     ! if (r < 0.33) then
     !    point = g(point)
     !    color = [0.5, 0., .1]
     ! if (r < 0.66) then
     !    point = f(point)
     !    color = [1., 0.1, 0.]
     ! else
     !    point = h(point)
     !    color = [0., 0.1, 1.]
     ! end if

     point = f(point)
          
     call draw_point(point * zoom + cmplx(WIDTH / 2, HEIGHT / 2), color, local_image)
  end do
  !$omp end do

  !$omp critical
  call stack_image(local_image)
  !$omp end critical
  
  !$omp end parallel

  call write_image(gain=GAIN, filename=FILENAME)

end program ifs
