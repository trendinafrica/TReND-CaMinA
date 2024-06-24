### Solution ### 
def neuron_model(I, baseline=0.0, threshold=1.0, dt=0.1, r_timer=0.5, tau=5, thr_i=2, thr_tau=50): 
    time_steps = len(I) # the number of time-steps in the simulation
    v = np.ones(time_steps) * baseline # membrane potential  
    spikes = [] # a list to store spike times 
    r_time = 0 # initialise refractory timer 
    dynamic_threshold = threshold # initialise dynamic threshold
    thr_list = []

    for time in range(time_steps - 1):

        if r_time > 0: 
            v[time] = baseline # reset membrane potential 
            r_time -= dt # decrement timer 

        elif v[time] > dynamic_threshold:
            spikes.append(time * dt) # record spike time 
            v[time] = baseline # reset membrane potential 
            r_time = r_timer # start refractory timer 
            dynamic_threshold += thr_i # increase the spiking threshold  

        dvdt = (I[time]-v[time])/tau  # calculate update 
        v[time + 1] = v[time] + dvdt*dt # update membrane potential
        dynamic_threshold += (threshold - dynamic_threshold)/thr_tau 

        thr_list.append(dynamic_threshold)

    return v, np.array(spikes)