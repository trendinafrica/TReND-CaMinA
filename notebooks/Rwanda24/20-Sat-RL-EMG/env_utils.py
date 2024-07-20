"""Utility functions for grid worlds."""
import numpy as np
import networkx as nx


def list_actions(transitions_dict):
  return sorted(np.unique([a for _, a in transitions_dict.keys()]))


def list_states(transitions_dict):
  return sorted(np.unique([a for s, a in transitions_dict.keys()] + list(transitions_dict.values())))


def transition_dict_to_networkx(transition_dict):
  states = list_states(transition_dict)
  n_states = len(states)
  g = nx.DiGraph()
  for (s, a), s_next in transition_dict.items():
    g.add_edge(s, s_next, action=a)
  return g


def map_to_array(map, map_to_arr_dict = None):
  rows = [row for row in map.split('\n') if row != '']
  n = len(rows)
  m = len(rows[0])
  arr = np.zeros((n, m), dtype=str)
  for i, row in enumerate(rows):
    for j, val in enumerate(row):
      arr[i, j] = val
  return arr


def get_coord_to_index_dict(n, m):
  coords = np.array(np.meshgrid(range(n), range(m))).reshape(2, -1).T
  return {(ii, jj): kk for kk, (ii, jj) in enumerate(coords)}


def get_index_to_coord_dict(n, m):
  coords = np.array(np.meshgrid(range(n), range(m))).reshape(2, -1).T
  return {kk: (ii, jj) for kk, (ii, jj) in enumerate(coords)}


def index_to_coord(k, n):
  i = k // n
  j = k % n
  return i, j


def arr_to_transition_dict(
    arr, start_symbol = 'S', boundary_symbol = 'X', reward_symbols = ['G', 'P'],
    reward_amounts = {'G': 1., 'P': -1.}):

  transitions = {}
  reward_probabilities = {}

  coords_to_inds = get_coord_to_index_dict(*arr.shape)
  inds_to_coords = get_index_to_coord_dict(*arr.shape)
  start_state = 0
  n_states = np.max(list(inds_to_coords.keys())) + 1

  pos = np.zeros((n_states, 2), dtype=int)

  inds = np.array(np.meshgrid(range(arr.shape[0]), range(arr.shape[1]))).reshape(2, -1).T
  for state, (x, y) in inds_to_coords.items():
    pos[state] = [y, arr.shape[0]-x-1]

    symbol = arr[x, y]
    if symbol in reward_symbols:
      reward_probabilities[state] = reward_amounts[symbol]
    else:
      reward_probabilities[state] = 0.

    if symbol == start_symbol:
      start_state = state

    # Get adjacent states coords.
    possible_next_state_coords = [(x+1, y), (x, y+1), (x-1, y), (x, y-1)]

    for action, (xx, yy) in enumerate(possible_next_state_coords):
      next_x, next_y = (xx, yy)

      # If current state is on a boundary, no external transitions
      # are possible -- all actions lead to stay.
      if symbol == boundary_symbol:
        next_x, next_y = (x, y)

      # If action leads you to a next_state that is out of bounds, 
      # replace next_state with staying at same state.
      if ((next_x < 0) or (next_x >= arr.shape[0]) or
          (next_y < 0) or (next_y >= arr.shape[1])):
        next_x, next_y = (x, y)

      # If next_state is an obstacle or wall, replace next state with current.
      if arr[next_x, next_y] == boundary_symbol:
        next_x, next_y = (x, y)

      next_state = coords_to_inds[(next_x, next_y)]
      transitions[(state, action)] = next_state


  return transitions, reward_probabilities, start_state, pos

