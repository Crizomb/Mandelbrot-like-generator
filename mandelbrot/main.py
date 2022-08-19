import moderngl_window as mglw




class App(mglw.WindowConfig):
    center_pos = [0, 0]
    window_size = 1800, 1000
    zoom = 1
    nb_itter = 255
    resource_dir = 'resources'
    param1 = 2


    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.quad = mglw.geometry.quad_fs()
        self.zooming = 0

        #self.quad = mglw.geometry.bbox()
        self.program = self.load_program(vertex_shader='programs/vertex.glsl',
                                         fragment_shader='programs/fragment.glsl')

        self.set_uniform('param1', self.param1)
        self.set_uniform('resolution', self.window_size)
        self.set_uniform('center_pos', tuple(self.center_pos))
        self.set_uniform('zoom', self.zoom)
        self.set_uniform('nb_itter', self.nb_itter)


    def set_uniform(self, u_name, u_value):
        try:
            self.program[u_name] = u_value
        except KeyError:
            None
            print(f'{u_name} not used in shader')


    def render(self, time, frame_time):
        self.ctx.clear()
        self.set_uniform('time', time)
        self.quad.render(self.program)





    def mouse_press_event(self, x, y, button):

        print("Mouse button {} pressed at {}, {}".format(button, x, y))
        nx, ny = x/self.window_size[0], y/self.window_size[1]

        dx, dy = (4*nx - 2)/self.zoom, (4*ny -2)/self.zoom
        self.center_pos[0] += dx
        self.center_pos[1] -= dy
        if button == 1:
            self.zoom *= 2
        else:
            self.zoom *= 0.5

        self.set_uniform('center_pos', tuple(self.center_pos))
        self.set_uniform('zoom', self.zoom)

    def key_event(self, key, action, modifiers):
        # Key presses
        if action == self.wnd.keys.ACTION_PRESS:

            if key == self.wnd.keys.UP:
                self.nb_itter += 100
            if key == self.wnd.keys.DOWN:
                self.nb_itter -= 100


            if key == self.wnd.keys.RIGHT:
                self.param1 += 0.01

            if key == self.wnd.keys.LEFT:
                self.param1 -= 0.01


            self.set_uniform('nb_itter', max(self.nb_itter, 10))
            self.set_uniform('param1', self.param1)




if __name__ == '__main__':
    mglw.run_window_config(App)
