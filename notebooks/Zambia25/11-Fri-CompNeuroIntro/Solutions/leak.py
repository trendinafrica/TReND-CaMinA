### Solution ###  
def neuron_model(I, baseline=0.0, threshold=1.0, dt=0.1, r_timer=0.5, tau=5): 

    time_steps = len(I) # the number of time-steps in the simulation
    v = np.ones(time_steps) * baseline # membrane potential  
    spikes = [] # a list to store spike times 
    r_time = 0 # initialise refractory timer 

    for time in range(time_steps - 1):

        if r_time > 0: 
            v[time] = baseline # reset membrane potential 
            r_time -= dt # decrement timer 

        elif v[time] > threshold:
            spikes.append(time * dt) # record spike time 
            v[time] = baseline # reset membrane potential 
            r_time = r_timer # start refractory timer 

        dvdt = (I[time]-v[time])/tau  # calculate update 
        v[time + 1] = v[time] + dvdt*dt # update membrane potential

    return v, np.array(spikes)