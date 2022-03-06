# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
from scipy.io import loadmat
from fooof import FOOOF
import numpy as np 

test = loadmat('fooof_example.mat')
avg_power = test['avg_power'].squeeze()
freqs = 2**np.linspace(1,5,num=9)

fm = FOOOF(peak_width_limits=[1.0, 8.0], max_n_peaks=6, min_peak_height=0.1, peak_threshold=2.0, aperiodic_mode='fixed')
fm.fit(freqs, avg_power,  [freqs.min(),freqs.max()])
fooof_ap_fit = 10 ** fm._ap_fit


from scipy.io import savemat
savemat('fooof_ap_fit.mat',{'foof_ap_fit':fooof_ap_fit})
