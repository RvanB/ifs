program ifs
  use omp_lib
  use functions
  use rendering
  implicit none

  ! ---------- VARIABLES & CONSTANTS ----------

  ! Parameters
  integer(4), parameter :: ITERATIONS=10**8

  ! Variables
  real :: color(3)

  ! Thread private variables
  complex :: point
  real :: r
  real, allocatable :: local_image(:,:,:)

  ! ---------- MAIN SECTION ----------

  ! Define functions
  complex :: f, g, h
  f(point) = tan(ring(point, n=5, radius=1.0, ratio=0.5))
  g(point) = ring(point, n=6, radius=1.0, ratio=0.5)
  h(point) = point

  ! Allocate image
  ! call allocate_image()

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

     ! point = h(g(f(point)))
     call random_number(r)
     if (r < 0.6) then
        point = f(point)
        color = (/0., 0.1, 1./)
     else 
        point = g(point)
        color = (/0.2, .5, 0.7/)
     end if

     ! point = ring(point, 5, 1., 0.5)
          
     call draw_point(point, color, local_image)
  end do
  !$omp end do

  !$omp critical
  call stack_image(local_image)
  ! deallocate(local_image)
  !$omp end critical

  !$omp end parallel

  call write_image(gain=2.5)
  ! call deallocate_image()

end program ifs
