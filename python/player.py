from collections import deque
import pickle

memory_buffer = deque(maxlen=1000)


with open('data.pickle', 'wb') as f:
    pickle.dump(memory_buffer,f)