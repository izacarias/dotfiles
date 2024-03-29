#!/usr/bin/env python2

"""
TODO: Transforming points isn't quite perfect, to say the least. In particular,
    when translating a point bezier curve, we translate the handles by the same amount.
    BUT, some handles that are attached to a particular point are conceptually
    handles of the prev/next node.
    Best way to fix it would be to keep a list of the fractional_offsets[] of
    each point, without transforming anything. Then go thru each point and
    transform the appropriate handle according to the relevant fraction_offset
    in the list.
    
    i.e. calculate first, then modify.
    
    In fact, that might be a simpler algorithm anyway -- it avoids having
    to keep track of all the first_xy/next_xy guff.

TODO: This doesn't work very well on paths which have both straight segments
      and curved segments.
      The biggest three problems are:
        a) we don't take handles into account (segments where the nodes are
           aligned are always treated as straight segments, even where the
           handles make it curve)
        b) when we snap a straight segment right before/after a curve, it
           doesn't make any attempt to keep the transition from the straight
           segment to the curve smooth.
        c) no attempt is made to keep equal widths equal. (or nearly-equal
           widths nearly-equal). For example, font strokes.
        
    I guess that amounts to the problem that font hinting solves for fonts.
    I wonder if I could find an automatic font-hinting algorithm and munge
    it to my purposes?
    
    Some good autohinting concepts that may help:
    http://freetype.sourceforge.net/autohinting/archive/10Mar2000/hinter.html

"""

from __future__ import division

import sys
from numpy import matrix
import simplestyle, simpletransform, simplepath

# INKEX MODULE
# If you get the "No module named inkex" error, uncomment the relevant line
# below by removing the '#' at the start of the line.
#
#sys.path += ['/usr/share/inkscape/extensions']                     # If you're using a standard Linux installation
#sys.path += ['/usr/local/share/inkscape/extensions']               # If you're using a custom Linux installation
#sys.path += ['C:\\Program Files\\Inkscape\\share\\extensions']     # If you're using a standard Windows installation

try:
    import inkex
    from inkex import unittouu
except ImportError:
    raise ImportError("No module named inkex.\nPlease edit the file %s and see the section titled 'INKEX MODULE'" % __file__)

Precision = 5                   # number of digits of precision for comparing float numbers

MaxGradient = 1/200             # lines that are almost-but-not-quite straight will be snapped, too.

class TransformError(Exception): pass

def elemtype(elem, matches):
    if not isinstance(matches, (list, tuple)): matches = [matches]
    for m in matches:
        if elem.tag == inkex.addNS(m, 'svg'): return True
    return False

def invert_transform(transform):
    transform = transform[:]    # duplicate list to avoid modifying it
    transform += [[0, 0, 1]]
    inverse = matrix(transform).I.tolist()
    inverse.pop()
    return inverse

def transform_point(transform, pt, inverse=False):
    """ Better than simpletransform.applyTransformToPoint,
        a) coz it's a simpler name
        b) coz it returns the new xy, rather than modifying the input
    """
    if inverse:
        transform = invert_transform(transform)
    
    x = transform[0][0]*pt[0] + transform[0][1]*pt[1] + transform[0][2]
    y = transform[1][0]*pt[0] + transform[1][1]*pt[1] + transform[1][2]
    return x,y

def transform_dimensions(transform, width=None, height=None, inverse=False):
    """ Dimensions don't get translated. I'm not sure how much diff rotate/skew
        makes in this context, but we currently ignore anything besides scale.
    """
    if inverse: transform = invert_transform(transform)

    if width is not None: width *= transform[0][0]
    if height is not None: height *= transform[1][1]
    
    if width is not None and height is not None: return width, height
    if width is not None: return width
    if height is not None: return height


def vertical(pt1, pt2):
    hlen = abs(pt1[0] - pt2[0])
    vlen = abs(pt1[1] - pt2[1])
    if vlen==0 and hlen==0:
        return True
    elif vlen==0:
        return False
    return (hlen / vlen) < MaxGradient

def horizontal(pt1, pt2):
    hlen = round(abs(pt1[0] - pt2[0]), Precision)
    vlen = round(abs(pt1[1] - pt2[1]), Precision)
    if hlen==0 and vlen==0:
        return True
    elif hlen==0:
        return False
    return (vlen / hlen) < MaxGradient

class PixelSnapEffect(inkex.Effect):
    def elem_offset(self, elem, parent_transform=None):
        """ Returns a value which is the amount the
            bounding-box is offset due to the stroke-width.
            Transform is taken into account.
        """
        transform = self.transform(elem, parent_transform=parent_transform)

        if abs(abs(transform[0][0]) - abs(transform[1][1])) > (10**-Precision):
            raise TransformError("Selection contains non-symetric scaling")

        stroke_width = self.stroke_width(elem)
        stroke_width = transform_dimensions(transform, width=stroke_width)

        return (stroke_width/2)

    def stroke_width(self, elem, setval=None):
        """ Return stroke-width in pixels, untransformed
        """
        style = simplestyle.parseStyle(elem.attrib.get('style', ''))
        stroke = style.get('stroke', None)
        if stroke == 'none': stroke = None
            
        stroke_width = 0
        if stroke and setval is None:
            stroke_width = unittouu(style.get('stroke-width', '').strip())
            
        if setval:
            style['stroke-width'] = str(setval)
            elem.attrib['style'] = simplestyle.formatStyle(style)
        else:
            return stroke_width

    def snap_stroke(self, elem, parent_transform=None):
        transform = self.transform(elem, parent_transform=parent_transform)

        if abs(abs(transform[0][0]) - abs(transform[1][1])) > (10**-Precision):
            raise TransformError("Selection contains non-symetric scaling")

        stroke_width = self.stroke_width(elem)
        
        if stroke_width:
            stroke_width = transform_dimensions(transform, width=stroke_width)
            stroke_width = round(stroke_width)
            stroke_width = transform_dimensions(transform, width=stroke_width, inverse=True)
            self.stroke_width(elem, stroke_width)

    def transform(self, elem, setval=None, parent_transform=None):
        """ Gets this element's transform. Use setval=matrix to
            set this element's transform.
            You can only specify parent_transform when getting.
        """
        transform = elem.attrib.get('transform', '').strip()
        
        if transform:
            transform = simpletransform.parseTransform(transform)
        else:
            transform = [[1,0,0], [0,1,0], [0,0,1]]
        if parent_transform:
            transform = simpletransform.composeTransform(parent_transform, transform)
            
        if setval:
            elem.attrib['transform'] = simpletransform.formatTransform(setval)
        else:
            return transform

    def snap_transform(self, elem):
        # Only snaps the x/y translation of the transform, nothing else.
        # Scale transforms are handled only in snap_rect()
        # Doesn't take any parent_transform into account -- assumes
        # that the parent's transform has already been snapped.
        transform = self.transform(elem)
        if transform[0][1] or transform[1][0]: return           # if we've got any skew/rotation, get outta here
 
        transform[0][2] = round(transform[0][2])
        transform[1][2] = round(transform[1][2])
        
        self.transform(elem, transform)
    
    def transform_path_node(self, transform, path, i):
        """ Modifies path so that every point is transformed, including handles
        """
        segtype = path[i][0].lower()
        
        if segtype == 'z': return
        elif segtype == 'h':
            path[i][1][0] = transform_point(transform, [path[i][1][0], 0])[0]
        elif segtype == 'v':
            path[i][1][0] = transform_point(transform, [0, path[i][1][0]])[1]
        else:
            for j in range(0, len(path[i][1]), 2):
                x, y = path[i][1][j], path[i][1][j+1]
                x, y = transform_point(transform, (x, y))
                path[i][1][j] = x
                path[i][1][j+1] = y
        
    
    def pathxy(self, path, i, setval=None):
        segtype = path[i][0].lower()
        x = y = 0

        if segtype == 'z': i = 0

        if segtype == 'h':
            if setval: path[i][1][0] = setval[0]
            else: x = path[i][1][0]
            
        elif segtype == 'v':
            if setval: path[i][1][0] = setval[1]
            else: y = path[i][1][0]
        else:
            if setval and segtype != 'z':
                path[i][1][-2] = setval[0]
                path[i][1][-1] = setval[1]
            else:
                x = path[i][1][-2]
                y = path[i][1][-1]

        if setval is None: return [x, y]
    
    def path_bounding_box(self, elem, parent_transform=None):
        """ Returns [min_x, min_y], [max_x, max_y] of the transformed
            element. (It doesn't make any sense to return the untransformed
            bounding box, with the intent of transforming it later, because
            the min/max points will be completely different points)
            
            The returned bounding box includes stroke-width offset.
        """
        # If we have a Live Path Effect, modify original-d. If anyone clamours
        # for it, we could make an option to ignore paths with Live Path Effects
        original_d = '{%s}original-d' % inkex.NSS['inkscape']
        path = simplepath.parsePath(elem.attrib.get(original_d, elem.attrib['d']))

        transform = self.transform(elem, parent_transform=parent_transform)
        offset = self.elem_offset(elem, parent_transform)
        
        min_x = min_y = max_x = max_y = 0
        for i in range(len(path)):
            x, y = self.pathxy(path, i)
            x, y = transform_point(transform, (x, y))
            
            if i == 0:
                min_x = max_x = x
                min_y = max_y = y
            else:
                min_x = min(x, min_x)
                min_y = min(y, min_y)
                max_x = max(x, max_x)
                max_y = max(y, max_y)
        
        return (min_x-offset, min_y-offset), (max_x+offset, max_y+offset)
            
    
    def snap_path_scale(self, elem, parent_transform=None):
        # If we have a Live Path Effect, modify original-d. If anyone clamours
        # for it, we could make an option to ignore paths with Live Path Effects
        original_d = '{%s}original-d' % inkex.NSS['inkscape']
        path = simplepath.parsePath(elem.attrib.get(original_d, elem.attrib['d']))
        transform = self.transform(elem, parent_transform=parent_transform)
        min_xy, max_xy = self.path_bounding_box(elem, parent_transform)
        
        width = max_xy[0] - min_xy[0]
        height = max_xy[1] - min_xy[1]
        rescale = round(width)/width, round(height)/height

        min_xy = transform_point(transform, min_xy, inverse=True)
        max_xy = transform_point(transform, max_xy, inverse=True)

        for i in range(len(path)):
            self.transform_path_node([[1, 0, -min_xy[0]], [0, 1, -min_xy[1]]], path, i)     # center transform
            self.transform_path_node([[rescale[0], 0, 0],
                                       [0, rescale[1], 0]],
                                       path, i)
            self.transform_path_node([[1, 0, +min_xy[0]], [0, 1, +min_xy[1]]], path, i)     # uncenter transform
        
        path = simplepath.formatPath(path)
        if original_d in elem.attrib: elem.attrib[original_d] = path
        else: elem.attrib['d'] = path

    def snap_path_pos(self, elem, parent_transform=None):
        # If we have a Live Path Effect, modify original-d. If anyone clamours
        # for it, we could make an option to ignore paths with Live Path Effects
        original_d = '{%s}original-d' % inkex.NSS['inkscape']
        path = simplepath.parsePath(elem.attrib.get(original_d, elem.attrib['d']))
        transform = self.transform(elem, parent_transform=parent_transform)
        min_xy, max_xy = self.path_bounding_box(elem, parent_transform)

        fractional_offset = min_xy[0]-round(min_xy[0]), min_xy[1]-round(min_xy[1])-self.document_offset
        fractional_offset = transform_dimensions(transform, fractional_offset[0], fractional_offset[1], inverse=True)

        for i in range(len(path)):
            self.transform_path_node([[1, 0, -fractional_offset[0]],
                                       [0, 1, -fractional_offset[1]]],
                                       path, i)

        path = simplepath.formatPath(path)
        if original_d in elem.attrib: elem.attrib[original_d] = path
        else: elem.attrib['d'] = path

    def snap_path(self, elem, parent_transform=None):
        # If we have a Live Path Effect, modify original-d. If anyone clamours
        # for it, we could make an option to ignore paths with Live Path Effects
        original_d = '{%s}original-d' % inkex.NSS['inkscape']
        path = simplepath.parsePath(elem.attrib.get(original_d, elem.attrib['d']))

        transform = self.transform(elem, parent_transform=parent_transform)

        if transform[0][1] or transform[1][0]:          # if we've got any skew/rotation, get outta here
            raise TransformError("Selection contains transformations with skew/rotation")
        
        offset = self.elem_offset(elem, parent_transform) % 1
        
        prev_xy = self.pathxy(path, -1)
        first_xy = self.pathxy(path, 0)
        for i in range(len(path)):
            segtype = path[i][0].lower()
            xy = self.pathxy(path, i)
            if segtype == 'z':
                xy = first_xy
            if (i == len(path)-1) or \
               ((i == len(path)-2) and path[-1][0].lower() == 'z'):
                next_xy = first_xy
            else:
                next_xy = self.pathxy(path, i+1)
            
            if not (xy and prev_xy and next_xy):
                prev_xy = xy
                continue
            
            xy_untransformed = tuple(xy)
            xy = list(transform_point(transform, xy))
            prev_xy = transform_point(transform, prev_xy)
            next_xy = transform_point(transform, next_xy)
            
            on_vertical = on_horizontal = False
            
            if horizontal(xy, prev_xy):
                if len(path) > 2 or i==0:                   # on 2-point paths, first.next==first.prev==last and last.next==last.prev==first
                    xy[1] = prev_xy[1]                      # make the almost-equal values equal, so they round in the same direction
                on_horizontal = True
            if horizontal(xy, next_xy):
                on_horizontal = True
            
            if vertical(xy, prev_xy):                       # as above
                if len(path) > 2 or i==0:
                    xy[0] = prev_xy[0]
                on_vertical = True
            if vertical(xy, next_xy):
                on_vertical = True

            prev_xy = tuple(xy_untransformed)
            
            fractional_offset = [0,0]
            if on_vertical:
                fractional_offset[0] = xy[0] - (round(xy[0]-offset) + offset)
            if on_horizontal:
                fractional_offset[1] = xy[1] - (round(xy[1]-offset) + offset) - self.document_offset
            
            fractional_offset = transform_dimensions(transform, fractional_offset[0], fractional_offset[1], inverse=True)
            self.transform_path_node([[1, 0, -fractional_offset[0]],
                                       [0, 1, -fractional_offset[1]]],
                                       path, i)


        path = simplepath.formatPath(path)
        if original_d in elem.attrib: elem.attrib[original_d] = path
        else: elem.attrib['d'] = path

    def snap_rect(self, elem, parent_transform=None):
        transform = self.transform(elem, parent_transform=parent_transform)

        if transform[0][1] or transform[1][0]:          # if we've got any skew/rotation, get outta here
            raise TransformError("Selection contains transformations with skew/rotation")
        
        offset = self.elem_offset(elem, parent_transform) % 1

        width = unittouu(elem.attrib['width'])
        height = unittouu(elem.attrib['height'])
        x = unittouu(elem.attrib['x'])
        y = unittouu(elem.attrib['y'])

        width, height = transform_dimensions(transform, width, height)
        x, y = transform_point(transform, [x, y])

        # Snap to the nearest pixel
        height = round(height)
        width = round(width)
        x = round(x - offset) + offset                  # If there's a stroke of non-even width, it's shifted by half a pixel
        y = round(y - offset) + offset
        
        width, height = transform_dimensions(transform, width, height, inverse=True)
        x, y = transform_point(transform, [x, y], inverse=True)
        
        y += self.document_offset/transform[1][1]
        
        # Position the elem at the newly calculate values
        elem.attrib['width'] = str(width)
        elem.attrib['height'] = str(height)
        elem.attrib['x'] = str(x)
        elem.attrib['y'] = str(y)
    
    def snap_image(self, elem, parent_transform=None):
        self.snap_rect(elem, parent_transform)
    
    def pixel_snap(self, elem, parent_transform=None):
        if elemtype(elem, 'g'):
            self.snap_transform(elem)
            transform = self.transform(elem, parent_transform=parent_transform)
            for e in elem:
                try:
                    self.pixel_snap(e, transform)
                except TransformError, e:
                    print >>sys.stderr, e
            return

        if not elemtype(elem, ('path', 'rect', 'image')):
            return

        self.snap_transform(elem)
        self.snap_stroke(elem, parent_transform)

        if elemtype(elem, 'path'):
            self.snap_path_scale(elem, parent_transform)
            self.snap_path_pos(elem, parent_transform)
            self.snap_path(elem, parent_transform)                      # would be quite useful to make this an option, as scale/pos alone doesn't mess with the path itself, and works well for sans-serif text
        elif elemtype(elem, 'rect'): self.snap_rect(elem, parent_transform)
        elif elemtype(elem, 'image'): self.snap_image(elem, parent_transform)

    def effect(self):
        svg = self.document.getroot()
        
        self.document_offset = unittouu(svg.attrib['height']) % 1       # although SVG units are absolute, the elements are positioned relative to the top of the page, rather than zero

        for id, elem in self.selected.iteritems():
            try:
                self.pixel_snap(elem)
            except TransformError, e:
                print >>sys.stderr, e


if __name__ == '__main__':
    effect = PixelSnapEffect()
    effect.affect()

