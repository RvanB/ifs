program ifs
  implicit none
  ! Constants
  real(8), parameter :: PI=4.D0*DATAN(1.D0)

  ! Parameters
  real, parameter :: zoom=1000
  integer, parameter :: N = 9
  integer, parameter :: W=1024, H=1024
  integer, parameter :: ITERATIONS=10**8

  ! Variables
  real, dimension(3, H, W) :: matrix = 0
  real :: theta
  integer :: file_unit, i
  real, dimension(2, N) :: points
  real, dimension(3) :: color
  real :: r
  real :: point(2), new_point(2)

  real, dimension(3, N):: colors

  ! Generate and draw initial points
  do i = 1, N
     theta = 2 * PI * (i-1) / N

     points(1, i) = cos(theta)
     points(2, i) = sin(theta)

     call random_number(colors(1, i))
     call random_number(colors(2, i))
     call random_number(colors(3, i))

     call draw_point(points(:, i), colors(:, i))
  end do

  point = points(:, N)
    
  ! Iterate
  do i = 1, ITERATIONS
     call random_number(r)
     
     point = (point + points(:, int(r * N) + 1)) / 2.3

     new_point(1) = point(1) + sin(0.5 * point(2)) * (point(1) * point(2))**4
     new_point(2) = point(2) + cos(2 * point(1)) * (point(1) * point(2))

     point = new_point

          
     call draw_point(point, colors(:, int(r * N) + 1))
  end do
  
  call write_image(matrix=matrix, path="image.ppm", gain=1.0)

contains

  subroutine draw_point(point, color)
    real, intent(in) :: point(2)
    real, intent(in) :: color(3)
    real :: x, y
    integer :: i, j
    
    i = int(point(2) * zoom) + H/2
    j = int(point(1) * zoom) + W/2

    if (i > 0 .and. i < H .and. j > 0 .and. j < W) then
       matrix(:, i, j) = matrix(:, i, j) + color
    endif

  end subroutine draw_point
    
  subroutine write_image(matrix, path, gain)
    real, intent(inout) :: matrix(3, H, W)
    real, intent(in) :: gain
    character(len=*), intent(in) :: path
    integer :: file_unit, x, y
    real :: r, g, b

    open(NEWUNIT=file_unit, file=path, status='replace', form='formatted')

    write(file_unit, '(A)') 'P3'
    write(file_unit, '(I4)') H
    write(file_unit, '(I4)') W
    write(file_unit, '(A)') '255' ! Max value

    matrix = (matrix - minval(matrix)) / (maxval(matrix) - minval(matrix)) * gain
    
    do y = 1, H
       do x = 1, W
          
          r = min(255.0, matrix(1, y, x) * 255.0)
          g = min(255.0, matrix(2, y, x) * 255.0)
          b = min(255.0, matrix(3, y, x) * 255.0)
          
          write(file_unit, '(I3, 1X, I3, 1X, I3, 1X)', advance='no') int(r), int(g), int(b)
       end do
    end do
    
    close(file_unit)
    Print *, path
  end subroutine write_image

end program ifs
