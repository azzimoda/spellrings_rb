module Spellrings
  class Visualizer
    private

    def draw_star(radius, size)
      if size <= 2
        draw_simple_star(radius)
      else
        draw_schlafli_star(radius, size)
      end
    end

    def draw_simple_star(radius)
      points = 5

      path_data = points.times.map do |i|
        angle = -Math::PI / 2 + Math::PI * 2 * i / points - Math::PI / 2
        x = radius * Math.cos(angle)
        y = radius * Math.sin(angle)
        i.zero? ? "M#{x},#{y}" : "L#{x},#{y}"
      end.join(' ') + ' Z'

      @svg.path d: path_data
    end

    def draw_schlafli_star(radius, size)
      full_step = (size * 2) / 5
      rings = gcd(size, full_step)
      points = size / rings
      step = full_step / rings

      rings.times do |ring_index|
        rotation_angle = 360.0 * ring_index / size

        path_data = schlafli_path_data radius, points, step, rotation_angle
        @svg.path d: path_data
      end
    end

    def schlafli_path_data(radius, points, step, rotation_angle)
      path_segments = []

      points.times do |i|
        current_angle = 2 * Math::PI * i / points - Math::PI / 2
        rotated_angle = current_angle + (rotation_angle * Math::PI / 180)
        x = radius * Math.cos(rotated_angle)
        y = radius * Math.sin(rotated_angle)

        path_segments << "M#{x},#{y}" if i.zero?

        next_index = (i * step) % points
        next_angle = 2 * Math::PI * next_index / points - Math::PI / 2
        next_rotated_angle = next_angle + (rotation_angle * Math::PI / 180)
        next_x = radius * Math.cos(next_rotated_angle)
        next_y = radius * Math.sin(next_rotated_angle)

        path_segments << "L#{next_x},#{next_y}"
      end

      path_segments << 'Z'
      path_segments.join ' '
    end

    def gcd(a, b)
      b.zero? ? a : gcd(b, a % b)
    end

    def point_on_circle(radius, angle_degrees)
      angle_rad = angle_degrees * Math::PI / 180
      [radius * Math.cos(angle_rad), radius * Math.sin(angle_rad)]
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
