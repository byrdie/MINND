
import numpy as np

from plot_velocity import plot_doppler_inten

from moses_animate import ani_frame




def plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, region=None, path='', outline=None, label='', y_ax = False, x_ax = False):

    p2_I = 'intensity/'
    p2_V = 'velocity/'
    p2_IV = 'intensity-velocity/'
    p3_z = 'zero/'
    p3_p = 'plus/'
    p3_m = 'minus/'
    p3_zp = 'zero-plus/'
    p3_zm = 'zero-minus/'
    p3_za = 'zero-ave/'

    if region != None:

        xmin = region[0][0]
        xmax = region[0][1]
        ymin = region[1][0]
        ymax = region[1][1]

        zero = zero[:, ymin:ymax, xmin:xmax]
        plus = plus[:, ymin:ymax, xmin:xmax]
        minus = minus[:, ymin:ymax, xmin:xmax]
        p_shift_plus = p_shift_plus[:, ymin:ymax, xmin:xmax]
        p_shift_minus = p_shift_minus[:, ymin:ymax, xmin:xmax]
        p_shift_ave = p_shift_ave[:, ymin:ymax, xmin:xmax]


    plot_doppler_inten(zero, p_shift_plus, path + p2_IV + p3_zp)
    plot_doppler_inten(zero, p_shift_minus, path + p2_IV + p3_zm)
    plot_doppler_inten(zero, p_shift_ave, path + p2_IV + p3_za, outline=outline, label=label, y_ax=y_ax, x_ax=x_ax)

    ani_frame(zero, path + p2_I + p3_z, outline=outline, label=label)
    ani_frame(plus, path + p2_I + p3_p)
    ani_frame(minus, path + p2_I + p3_m)

    ps_plus_max = np.nanmax(np.abs(p_shift_plus))
    ps_minus_max = np.nanmax(np.abs(p_shift_minus))
    ps_ave_max = np.nanmax(np.abs(p_shift_ave))
    ani_frame(p_shift_plus, path + p2_V + p3_zp, vmin=-ps_plus_max, vmax=ps_plus_max)
    ani_frame(p_shift_minus, path + p2_V + p3_zm, vmin=-ps_minus_max, vmax=ps_minus_max)
    ani_frame(p_shift_ave, path + p2_V + p3_za, vmin=-ps_ave_max, vmax=ps_ave_max)

