module functions
  implicit none

  real, parameter :: PI = 3.14159

contains

  complex function ring(point, n, radius, ratio)
    complex, intent(in) :: point
    integer, intent(in) :: n
    real, intent(in) :: radius
    real, intent(in) :: ratio

    complex :: target_point

    real :: r, theta
    integer :: i

    call random_number(r)
    i = int(r * n)
    theta = 2 * PI / n * i

    target_point = cmplx(cos(theta) * radius, sin(theta) * radius)

    ring = (point + target_point) * ratio
  end function ring

  complex function unit_rand()
    real :: r(2)
    call random_number(r)
    unit_rand = cmplx(r(1), r(2)) * 2 - 1
  end function unit_rand

end module functions
