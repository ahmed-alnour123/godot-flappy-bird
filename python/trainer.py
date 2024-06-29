import asyncio
import websockets
import json


import time
from collections import deque, namedtuple

import numpy as np
import tensorflow as tf
import utils

from tensorflow.keras import Sequential
from tensorflow.keras.layers import Dense, Input
from tensorflow.keras.losses import MSE
from tensorflow.keras.optimizers import Adam
from keras.models import load_model
import pickle


MEMORY_SIZE = 100_000_000     # size of memory buffer
GAMMA = 1            # discount factor
ALPHA = 1e-3              # learning rate  
NUM_STEPS_FOR_UPDATE = 4  # perform a learning update every C time steps

# Set the random seed for TensorFlow
tf.random.set_seed(utils.SEED)

state_size = [4]
num_actions = 2
def start_game():
    data = {'code':0}
    return json.dumps(data)

def reset(total_points):
    data = {'code':2,
            'total_points':total_points}
    return json.dumps(data)


def step(action):
    data = {'code':1,
            'action':action}
    return json.dumps(data)


# q_network = Sequential([
#     Input(shape=state_size),
#     Dense(units=128, activation='relu'),                      
#     Dense(units=128, activation='relu'),            
#     Dense(units=num_actions, activation='linear'),
#     ])

# target_q_network = Sequential([
#     Input(shape=state_size),
#     Dense(units=128, activation='relu'),                      
#     Dense(units=128, activation='relu'),            
#     Dense(units=num_actions, activation='linear'),
#     ])

test_number = 3

q_network = load_model(f"flappy_model3{test_number}.keras")
target_q_network = load_model(f"flappy_model3{test_number}.keras")


optimizer = Adam(learning_rate=ALPHA)

experience = namedtuple("Experience", field_names=["state", "action", "reward", "next_state", "done"])

def compute_loss(experiences, gamma, q_network, target_q_network):
    states, actions, rewards, next_states, done_vals = experiences
    
    # Compute max Q value for the next states using the target Q-network
    max_qsa = tf.reduce_max(target_q_network(next_states), axis=-1)
    
    # Compute the target Q values
    y_targets = rewards + (gamma * max_qsa * (1 - done_vals))
    
    # Get the Q values for the actions taken
    q_values = q_network(states)
    
    # Ensure actions are within valid range
    actions = tf.cast(actions, tf.int32)
    actions = tf.clip_by_value(actions, 0, q_values.shape[-1] - 1)
    
    action_indices = tf.stack([tf.range(tf.shape(q_values)[0]), actions], axis=1)
    q_values = tf.gather_nd(q_values, action_indices)
        
    # Compute the loss
    loss = MSE(y_targets, q_values)    
    return loss

@tf.function
def agent_learn(experiences, gamma):
    """
    Updates the weights of the Q networks.
    
    Args:
      experiences: (tuple) tuple of ["state", "action", "reward", "next_state", "done"] namedtuples
      gamma: (float) The discount factor.
    
    """
    
    # Calculate the loss
    with tf.GradientTape() as tape:
        loss = compute_loss(experiences, gamma, q_network, target_q_network)

    # Get the gradients of the loss with respect to the weights.
    gradients = tape.gradient(loss, q_network.trainable_variables)
    
    # Update the weights of the q_network.
    optimizer.apply_gradients(zip(gradients, q_network.trainable_variables))

    # update the weights of target q_network
    utils.update_target_network(q_network, target_q_network)


async def main():
    url = "ws://localhost:9080"
    async with websockets.connect(url) as websocket:
        
        start = time.time()

        num_episodes = 100000
        max_num_timesteps = 10000000

        total_point_history = []

        num_p_av = 100    # number of total points to use for averaging
        epsilon = 0.001     # initial ε value for ε-greedy policy

        # Create a memory buffer D with capacity N
        memory_buffer = deque(maxlen=MEMORY_SIZE)
        # with open('data.pickle', 'rb'   ) as f:
        #     memory_buffer = pickle.load(f) 

        # Set the target network weights equal to the Q-Network weights
        target_q_network.set_weights(q_network.get_weights())
        total_points = 0

        end = False
        for i in range(num_episodes):
            # Reset the environment to the initial state and get the initial state
            if i == 0:
                await websocket.send(start_game()) 
            else:
                await websocket.send(reset(total_points)) 
            response = json.loads(await websocket.recv())
            state = response['state']
            total_points = 0
            
            for t in range(max_num_timesteps):
                # From the current state S choose an action A using an ε-greedy policy
                state_qn = np.expand_dims(state, axis=0)  # state needs to be the right shape for the q_network
                q_values = q_network(state_qn)

                action = utils.get_action(q_values, epsilon)
                # action = np.argmax(q_values.numpy()[0])
                # Take action A and receive reward R and the next state S'
                await websocket.send(step(int(action))) 
                response = json.loads(await websocket.recv())
                if(response['code'] == 3):
                    end = True
                    break
                next_state = response['state']
                reward = response['reward']
                done = response['done_val']
                # print(next_state)

                # next_state, reward, done, _ = env.step(action)
                
                # Store experience tuple (S,A,R,S') in the memory buffer.
                # We store the done variable as well for convenience.
                memory_buffer.append(experience(state, action, reward, next_state, done))
                
                # Only update the network every NUM_STEPS_FOR_UPDATE time steps.
                update = utils.check_update_conditions(t, NUM_STEPS_FOR_UPDATE, memory_buffer)
                
                if update:
                    # Sample random mini-batch of experience tuples (S,A,R,S') from D
                    experiences = utils.get_experiences(memory_buffer)
                    
                    # Set the y targets, perform a gradient descent step,
                    # and update the network weights.
                    agent_learn(experiences, GAMMA)
                
                state = next_state.copy()
                
                total_points += reward
                if done == 1:
                    break
                    
            total_point_history.append(total_points)
            av_latest_points = np.mean(total_point_history[-num_p_av:])
            
            # Update the ε value
            epsilon = utils.get_new_eps(epsilon)

            print(f"Episode {i+1} | Reward: {total_points} average of last {num_p_av} episodes: {av_latest_points:.2f}")

            if (i+1) % num_p_av == 0:
                print(f"\rEpisode {i+1} | Total point average of the last {num_p_av} episodes: {av_latest_points:.2f}")

            # We will consider that the environment is solved if we get an
            # average of 200 points in the last 100 episodes.
            if end:
                print(f"\n\nEnvironment solved in {i+1} episodes!")
                q_network.save(f'flappy_model3{test_number+1}.keras')
                with open('data.pickle', 'wb') as f:
                    pickle.dump(memory_buffer,f)
                break
                
        tot_time = time.time() - start

        print(f"\nTotal Runtime: {tot_time:.2f} s ({(tot_time/60):.2f} min)")



if __name__ == '__main__':
    asyncio.run(main())


