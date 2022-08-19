#version 440 core


out vec4 fragColor;

uniform float param1;
uniform vec2 resolution;
uniform float time;
uniform vec2 center_pos;
uniform float zoom;
uniform int nb_itter;



vec2 get_euler_form(in vec2 c){
    vec2 result = vec2(0.0);
    float re = c.x;
    float im = c.y;
    float mod = sqrt(re*re + im*im);

    float angle = atan(im/re);
    if (re < 0){
        angle += 3.14159265359;
    }
    result.x = mod;
    result.y = angle;
    return result;
}
vec2 conjug(in vec2 c){
    vec2 result = vec2(0.0);
    result.x = c.x;
    result.y = -c.y;
    return result;
}

float mod_s(in vec2 c){
    return c.x*c.x + c.y*c.y;
}

vec2 mult_complex(in vec2 c1, in vec2 c2){
    vec2 result = vec2(0.0);
    float re = c1.x * c2.x - c1.y * c2.y;
    float im = c1.x * c2.y + c1.y * c2.x;
    result.x = re;
    result.y = im;
    return result;
}

vec2 div_complex(in vec2 c1, in vec2 c2){
    vec2 result = vec2(0.0);
    return mult_complex(c1, conjug(c2))/mod_s(c2);
}

vec2 complex_exp(in vec2 c){
    vec2 result = vec2(0.0);
    float expa = exp(c.x);
    result.x = expa*cos(c.y);
    result.y = expa*sin(c.y);
    return result;
}
vec2 complex_sin(vec2 c){
    vec2 i = vec2(0.0);
    i.y = 1.0;
    vec2 ic = mult_complex(c, i);
    return div_complex((complex_exp(ic) - complex_exp(-ic)), 2*i);
}

vec2 complex_cos(vec2 c){
    vec2 i = vec2(0.0);
    i.y = 1.0;
    vec2 ic = mult_complex(c, i);
    return (complex_exp(ic) + complex_exp(-ic))/2;
}


vec2 complex_sinh(in vec2 c){
    return (complex_exp(c)-complex_exp(-c))/2;
}

vec2 complex_cosh(in vec2 c){
    return (complex_exp(c)+complex_exp(-c))/2;
}

vec2 complex_tanh(in vec2 c){
    return div_complex(complex_sinh(c), complex_cosh(c));
}


vec2 complex_pow(in vec2 c, in float n){
    vec2 result = vec2(0.0);
    vec2 euler_form = get_euler_form(c);
    float mod = euler_form.x;
    float angle = euler_form.y;
    angle *= n;
    mod = pow(mod, n);

    result.x = mod*cos(angle);
    result.y = mod*sin(angle);

    return result;
}

vec2 squared(in vec2 c){
    vec2 result = vec2(0.0);
    result.x = c.x*c.x - c.y*c.y;
    result.y = 2*c.x*c.y;
    return result;
}

vec3 mandelbrot(in vec2 p, in int max_itt){
    vec2 c = vec2(0.0);
    for(int i=0; i< int(max_itt); i++)
    {
        if(sqrt(c.x*c.x + c.y*c.y) > 12)
        {
            float r = 1*i%255;
            float g = 2*i%255;
            float b = 3*i%255;
            return vec3(r/255, g/255, b/255);
        }
        // c = complex_pow(c, param1) + p;
        // c = complex_exp(c) + p;
        // c = complex_exp(complex_pow(c, param1)) + p;
        // c = complex_sin(complex_pow(c, param1)) + p;
        // c = complex_pow(complex_sin(c), param1) + p;
        c = complex_pow(c, 2) + p;
        vec2 one = vec2(0.0);
        one.x = 1;

        //c = div_complex(one, complex_exp(complex_pow(c, param1)) + p);
    }
    return vec3(0.0);
}

void main(){
    // vec2 uv = (gl_FragCoord.xy - 0.5 * resolution.xy) / resolution.y;
    vec2 uv = gl_FragCoord.xy;
    vec3 col = vec3(0.0);
    float cx = center_pos.x;
    float cy = center_pos.y;
    float zoom = zoom;
    float xn = (gl_FragCoord.x) / (resolution.x);
    float yn = (gl_FragCoord.y) / (resolution.y);
    float rx = (4*xn+cx*zoom - 2)/zoom;
    float ry = (4*yn+cy*zoom - 2)/zoom;

    vec2 p = vec2(0.0);
    p.x = rx;
    p.y = ry;

    col += mandelbrot(p, nb_itter);

    fragColor = vec4(col, 0.1);
}