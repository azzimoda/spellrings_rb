module Spellrings
  class Visualizer
    private

    def draw_star(num_points, step, radius)
      points = star_points num_points, step, radius
      svg.polygon points: points.map { it.join(',') }.join(' ')
    end

    def star_points(num_points, step, radius)
      points = num_points.times.map do |i|
        angle = 2 * Math::PI * i / num_points - Math::PI / 2
        [radius * Math.cos(angle), radius * Math.sin(angle)]
      end

      i = 0
      result = []
      num_points.times do
        result << points[i]
        i = (i + step) % num_points
        break if i.zero? && result.size > 1
      end
      result
    end

    def circle_sector(start_angle: 0, end_angle: 2 * Math::PI, **kwargs)
      kwargs.merge({ start_angle: start_angle, end_angle: end_angle })
      c = 2 * Math::PI * kwargs[:r]
      arc_length = c * (end_angle - start_angle) / (2 * Math::PI)

      transform = "#{kwargs[:transform]} rotate(#{start_angle * 180 / Math::PI} #{kwargs[:cx]} #{kwargs[:cy]})"
      @svg.circle(stroke_dasharray: "#{arc_length} #{c - arc_length}", transform: transform, **kwargs)
    end
  end
end
