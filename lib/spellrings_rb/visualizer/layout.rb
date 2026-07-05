# frozen_string_literal: true

module Spellrings
  class Visualizer
    private

    CHILD_MARGIN = 5.0

    def compute_layout(ring, center: Vector[0, 0], start_angle: 0)
      @layout_cache = {}
      @subtree_extent = {}

      4.times do
        compute_layout_pass(ring, center: center, start_angle: start_angle)
        compute_subtree_extents(ring)
      end
    end

    def compute_layout_pass(ring, center:, start_angle:)
      inner_radius = ring.radius(@font, @font_size)
      outer_radius = inner_radius + @line_height
      circle_length = ring.circle_length(@font, @font_size)

      children = []
      i = 0
      ring.elements.each do |el|
        if el.is_a?(Ring)
          child_inner = el.radius(@font, @font_size)
          child_outer = child_inner + @line_height
          child_bounds = @subtree_extent[el] || child_outer
          extra_bounds = [child_bounds - child_outer, 0].max
          base_bound = child_outer + extra_bounds * 0.94
          collision_bound = child_outer + extra_bounds * 0.3
          distance = [outer_radius + child_inner + @line_height * 2,
                      outer_radius + base_bound].max
          angle = rotation_angle(start_angle, i, el.width(@font, @font_size), circle_length)

          children << {
            element: el, distance: distance, angle: angle,
            child_inner: child_inner, child_bounds: collision_bound
          }
        end
        i += el.width(@font, @font_size) + @space_width
      end

      resolve_overlaps(children, center)

      children.each do |child|
        @layout_cache[[ring.object_id, child[:element].object_id]] = child[:distance]
        child_center = center + Vector[child[:distance] * Math.cos(child[:angle]),
                                        child[:distance] * Math.sin(child[:angle])]
        compute_layout_pass(child[:element], center: child_center, start_angle: -Math::PI / 2 + child[:angle])
      end
    end

    def compute_subtree_extents(ring)
      own_outer = ring.radius(@font, @font_size) + @line_height
      max_descendant = 0.0

      ring.elements.each do |el|
        next unless el.is_a?(Ring)

        compute_subtree_extents(el)

        child_dist = @layout_cache[[ring.object_id, el.object_id]]
        next unless child_dist

        child_extent = @subtree_extent[el] || (el.radius(@font, @font_size) + @line_height)
        total = child_dist + child_extent
        max_descendant = total if total > max_descendant
      end

      @subtree_extent[ring] = [own_outer, max_descendant].max
    end

    def resolve_overlaps(children, parent_center)
      return if children.size < 2

      200.times do
        any_overlap = false

        children.combination(2).each do |a, b|
          pos_a = parent_center + Vector[a[:distance] * Math.cos(a[:angle]),
                                          a[:distance] * Math.sin(a[:angle])]
          pos_b = parent_center + Vector[b[:distance] * Math.cos(b[:angle]),
                                          b[:distance] * Math.sin(b[:angle])]
          dx = pos_a[0] - pos_b[0]
          dy = pos_a[1] - pos_b[1]
          dist = Math.sqrt(dx * dx + dy * dy)
          min_dist = a[:child_bounds] + b[:child_bounds] + CHILD_MARGIN

          if dist < min_dist
            any_overlap = true
            push = (min_dist - dist) / 2.0
            total = a[:child_bounds] + b[:child_bounds]
            a[:distance] += push * 2 * a[:child_bounds] / total
            b[:distance] += push * 2 * b[:child_bounds] / total
          end
        end

        break unless any_overlap
      end
    end

    def layout_distance(ring, element)
      @layout_cache&.fetch([ring.object_id, element.object_id]) do
        outer_radius = ring.radius(@font, @font_size) + @line_height
        child_inner = element.radius(@font, @font_size)
        child_outer = child_inner + @line_height
        child_bounds = @subtree_extent&.fetch(element) { child_outer }
        extra = [child_bounds - child_outer, 0].max
        base_bound = child_outer + extra * 0.94
        [outer_radius + child_inner + @line_height * 2,
         outer_radius + base_bound].max
      end
    end
  end
end
