program ifs
  use omp_lib
  use functions
  use rendering
  implicit none

  ! ---------- SETTINGS ----------
  integer, parameter :: ITERATIONS=10**8
  integer, parameter :: WIDTH = 2000
  integer, parameter :: HEIGHT = 2000
  logical, parameter :: SUBTRACTIVE = .true.
  real, parameter :: BACKGROUND = [0., 0., 0.]
  real, parameter :: GAIN = 10
  real, parameter :: GAMMA = 10
  real, parameter :: ZOOM = 1500
  character(len=*), parameter :: FILENAME = "output.png"

  ! ---------- VARIABLES ----------
  real :: color(3)
  complex :: point
  real :: r
  real, allocatable :: local_image(:,:,:)

  complex :: ORIGIN = 0

  ! ---------- DEFINE FUNCTIONS ----------
  complex :: f
  f(point) = tan(ring(point, n=3, radius=.8, ratio=0.5))

  ! ---------- MAIN SECTION ----------
  ! Create WxH image
  call initialize_image(HEIGHT, WIDTH)

  ! Parallelize the main loop with OpenMP
  !$omp parallel private(point, r, local_image) shared(color, image)

  ! Allocate image on heap (rather than stack)
  allocate(local_image(4, HEIGHT, WIDTH))
  local_image = 0.0

  ! Create a random point in unit circle
  point = unit_rand()
  point = point * 2 - 1
  
  !$omp do schedule(static)
  do i = 1, ITERATIONS

     call random_number(r)

     if (r < 0.5) then
        point = f(point)
        color = [1., 0., 1.]
     else
        point = rotate(point, theta=pi, about=ORIGIN)
        point = f(point)
        color = [1., 1., 0.]
     end if

     if (SUBTRACTIVE) then
        color = 1 - color
     end if
          
     call draw_point(point * zoom + cmplx(WIDTH / 2, HEIGHT / 2), color, local_image)
  end do
  !$omp end do

  !$omp critical
  call stack_image(local_image)
  !$omp end critical
  
  !$omp end parallel

  call write_image(filename=FILENAME, gain=GAIN, gamma=GAMMA, invert=SUBTRACTIVE, bg_color=BACKGROUND)

end program ifs
