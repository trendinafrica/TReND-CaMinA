"""Plotting functions for tutorial."""
# TODO(stachenfeld): add documentation on functions

from typing import Optional
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
import seaborn as sns


COLORS = sns.color_palette('tab10')
BLUE, ORANGE, GREEN, RED, PURPLE, BROWN, PINK, GRAY, LIME, CYAN = COLORS
LINESTYLES = ['-', '--', ':', '-.']


def smooth(x, window_size: int, filter_type: str = 'center'):
  x = np.array(x, dtype=float)
  x_with_nans = np.insert(x, [0, len(x)], np.nan)
  ones_with_nans = np.insert(np.ones_like(x), [0, -1], np.nan)

  window_size = np.min([window_size, x.shape[0]])
  window = np.ones(window_size)

  assert filter_type in ['causal', 'center']
  mode = 'full' if filter_type == 'causal' else 'same'
  
  denom = np.convolve(ones_with_nans, window, mode=mode)[1:x.shape[0]+1]
  denom[denom==0] = 1
  x_smooth = np.convolve(x_with_nans, window, mode=mode)[1:x.shape[0]+1]
  x_smooth /= denom
  return x_smooth


def plot_with_smooth(y, ax = None, x=None, show_smooth: bool = True,
                     window_size: Optional[int] = None, filter_type: Optional[str] = 'center',
                     add_labels=True, stim_labels=None, state_action_q_values: bool = False):
  if ax is None:
    ax = plt.gca()

  if x is None:
    x = np.arange(len(y))

  y = np.array(y)
  if y.ndim == 1:
    y = y[:, None]

  marker = 'o' if len(y) == 1 else '-'
  alpha = 0.5 if show_smooth else 1.

  if show_smooth and (window_size is None):
      window_size = len(x)//10

  add_labels = add_labels and (y.shape[1] > 1)

  if add_labels:
    stim_labels = stim_labels or [f'Stim {i}' for i in range(y.shape[1])]
    if len(stim_labels) != y.shape[1]:
        raise ValueError('len(stim_labels) should equal y.shape[1] when multiple stimuli are present.')

  for i in range(y.shape[1]):
    label = stim_labels[i] if add_labels else None
    if state_action_q_values and (y.ndim == 3):
      for j in range(y.shape[2]):
        ax.plot(x, y[:, i, j], LINESTYLES[j%len(LINESTYLES)], alpha=alpha,
                color=COLORS[i%len(COLORS)], label=f'{label}, Action {j}')

    else:
      ax.plot(x, y[:, i], marker, alpha=alpha, color=COLORS[i%len(COLORS)], label=label)

    if show_smooth:
      ax.plot(x, smooth(y[:, i], window_size, filter_type), '-', color=COLORS[i%len(COLORS)])

  if add_labels:
    ax.legend()


def plot_learning_variables_over_time(
        data_to_plot, show_smooth: bool = False, window_size: Optional[int] = None,
        filter_type: Optional[str] = 'center', add_labels=True, stim_labels=None,
        state_action_q_values: bool = False):
  n_plots = len(data_to_plot)
  fig, axes = plt.subplots(1, n_plots, figsize=(4*n_plots, 4))
  for i in range(n_plots):
    ax = axes[i]
    varname, data = data_to_plot[i]
    plot_with_smooth(data, window_size=window_size, ax=ax, filter_type=filter_type, show_smooth=show_smooth,
                     add_labels=add_labels, stim_labels=stim_labels, state_action_q_values=state_action_q_values)
    ax.set_title(varname)
    ax.set_ylabel(varname)
    ax.set_xlabel("Timestep")
  return fig, axes


def add_vline(ax, x, *args, **kwargs):
  """Add vertical line(s) to plot(s)."""
  if not np.iterable(x):
    x = [x]
  x = np.array(x).reshape(-1)

  if not np.iterable(ax):
    axes = [ax]
  else:
    axes = ax.reshape(-1)

  for ax in axes:
    ylim = ax.get_ylim()
    for xi in x:
      ax.plot([xi, xi], ylim, *args, **kwargs)
    ax.set_ylim(ylim)


def plot_graph(graph, pos, ax = None, node_color = None, node_size: Optional[int] = 300,
               vmin: float = -0.2, vmax: float = 2., cmap = 'gray_r', do_labels=True,
               cbar: bool = False):
  if ax is None:
    ax = plt.gca()

  # Plot the MDP graph.
  labels = {n: n for n in graph.nodes} if do_labels else None
  img = nx.draw_networkx_nodes(graph, pos=pos, node_color=node_color, node_size=node_size, ax=ax,
                               vmin=vmin, vmax=vmax, cmap=cmap)
  nx.draw_networkx_labels(graph, pos, labels=labels, ax=ax)
  nx.draw_networkx_edges(graph, pos=pos, arrows=True, arrowstyle='-|>', node_size=node_size, ax=ax)
  if cbar:
    plt.colorbar(img, ax=ax)


def plot_grid_heatmap(pos, value: np.ndarray, ax = None, center_vaxis = False, **kwargs):
  if ax is None:
    ax = plt.gca()

  n, m = np.array(np.max(pos, axis=0)+1, dtype=int)
  map = np.zeros((m, n)) + np.nan

  for k, (i, j) in enumerate(pos):
    map[j, i] = value[k]

  if center_vaxis:
    vmax = np.abs(value.max())
    vmin = -vmax
    kwargs.update({'vmax': vmax, 'vmin': vmin})

  im = ax.imshow(map[::-1], **kwargs)
  return ax, im