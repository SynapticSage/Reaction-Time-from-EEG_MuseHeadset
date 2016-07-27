
# coding: utf-8

# # Table of Contents
#  <p><div class="lev1 toc-item"><a href="#Preamble" data-toc-modified-id="Preamble-1"><span class="toc-item-num">1&nbsp;&nbsp;</span>Preamble</a></div><div class="lev1 toc-item"><a href="#Input-CSV" data-toc-modified-id="Input-CSV-2"><span class="toc-item-num">2&nbsp;&nbsp;</span>Input CSV</a></div><div class="lev1 toc-item"><a href="#Modify-Muse-CSV" data-toc-modified-id="Modify-Muse-CSV-3"><span class="toc-item-num">3&nbsp;&nbsp;</span>Modify Muse CSV</a></div><div class="lev1 toc-item"><a href="#Data-Scrub:-Muse-File" data-toc-modified-id="Data-Scrub:-Muse-File-4"><span class="toc-item-num">4&nbsp;&nbsp;</span>Data Scrub: Muse File</a></div><div class="lev2 toc-item"><a href="#Unique-row-components" data-toc-modified-id="Unique-row-components-4.1"><span class="toc-item-num">4.1&nbsp;&nbsp;</span>Unique row components</a></div><div class="lev2 toc-item"><a href="#Helper-Functions" data-toc-modified-id="Helper-Functions-4.2"><span class="toc-item-num">4.2&nbsp;&nbsp;</span>Helper Functions</a></div><div class="lev2 toc-item"><a href="#Data-Structure-Creation" data-toc-modified-id="Data-Structure-Creation-4.3"><span class="toc-item-num">4.3&nbsp;&nbsp;</span>Data Structure Creation</a></div><div class="lev3 toc-item"><a href="#Functional-Data-Structure" data-toc-modified-id="Functional-Data-Structure-4.3.1"><span class="toc-item-num">4.3.1&nbsp;&nbsp;</span>Functional Data Structure</a></div><div class="lev4 toc-item"><a href="#EEG" data-toc-modified-id="EEG-4.3.1.1"><span class="toc-item-num">4.3.1.1&nbsp;&nbsp;</span>EEG</a></div><div class="lev4 toc-item"><a href="#Behavior" data-toc-modified-id="Behavior-4.3.1.2"><span class="toc-item-num">4.3.1.2&nbsp;&nbsp;</span>Behavior</a></div><div class="lev4 toc-item"><a href="#Description" data-toc-modified-id="Description-4.3.1.3"><span class="toc-item-num">4.3.1.3&nbsp;&nbsp;</span>Description</a></div><div class="lev1 toc-item"><a href="#Data-Scrub:-Game-File" data-toc-modified-id="Data-Scrub:-Game-File-5"><span class="toc-item-num">5&nbsp;&nbsp;</span>Data Scrub: Game File</a></div><div class="lev2 toc-item"><a href="#Modify/Input-Space-separated-File" data-toc-modified-id="Modify/Input-Space-separated-File-5.1"><span class="toc-item-num">5.1&nbsp;&nbsp;</span>Modify/Input Space-separated File</a></div><div class="lev2 toc-item"><a href="#Bring-into-pandas.DataFrame" data-toc-modified-id="Bring-into-pandas.DataFrame-5.2"><span class="toc-item-num">5.2&nbsp;&nbsp;</span>Bring into <code>pandas.DataFrame</code></a></div><div class="lev2 toc-item"><a href="#Create-game-dict-of-numpy-arrays" data-toc-modified-id="Create-game-dict-of-numpy-arrays-5.3"><span class="toc-item-num">5.3&nbsp;&nbsp;</span>Create <code>game</code> dict of <code>numpy</code> arrays</a></div><div class="lev1 toc-item"><a href="#Saving-Data" data-toc-modified-id="Saving-Data-6"><span class="toc-item-num">6&nbsp;&nbsp;</span>Saving Data</a></div><div class="lev2 toc-item"><a href="#Matlab-Native" data-toc-modified-id="Matlab-Native-6.1"><span class="toc-item-num">6.1&nbsp;&nbsp;</span>Matlab Native</a></div><div class="lev2 toc-item"><a href="#Python-Native" data-toc-modified-id="Python-Native-6.2"><span class="toc-item-num">6.2&nbsp;&nbsp;</span>Python Native</a></div><div class="lev3 toc-item"><a href="#Data-Frame" data-toc-modified-id="Data-Frame-6.2.1"><span class="toc-item-num">6.2.1&nbsp;&nbsp;</span>Data Frame</a></div><div class="lev3 toc-item"><a href="#EEG-/-Behavior-Dictionaries" data-toc-modified-id="EEG-/-Behavior-Dictionaries-6.2.2"><span class="toc-item-num">6.2.2&nbsp;&nbsp;</span>EEG / Behavior Dictionaries</a></div>

# **MUSE CSV SCRUB**
# 
#  Author | Ryan Y. 
# --------|--------
#  Point |  Carves up the huge Muse CSV file to separate data for the different submodules, then saves it into several data types usesable by python and matlab. For one, the entire data set is put into an easy but space expensive data frame format (saved), and into less expensive array formats stored into specific keys dictionaries. These dictionaries are sort of like matlab structs, who store specific things about the eeg signals and behavior in their fields. |
# Inputs | File path to a Muse CSV File, <a href="#csvinput">type into widget below</a>. This scrubber expects the game file to have the same title, but `.txt` instead of `.csv`.
# Outputs| A functional structure and sampling rate structures in formats readable by python and matlab |

# # Preamble

# In[35]:

# --- FLAGS AND BASIC SETTINGS --------------
# Plot options
# Whether to generate plots during scrub restructuring
plot_data_aspects = True
# "Inline" docked or "qt" floating
get_ipython().magic('matplotlib inline')
# "Inline" docked or "qt" floating
get_ipython().magic('pylab inline')
# Default figure size
pylab.rcParams['figure.figsize'] = (14, 10)
# Save options
# Whether to save pandas dataframe deriving dict/structs from
save_data_frame = False 
# Timestamp handling
# Whether to set first timestamp to 0
global timestamp_zerod
timestamp_zerod = True
# --------------------------------------------
    
# -----MODULES ----
#Debugging
import pdb

# save tool
import pickle

# Input/Output
import scipy.io
import pandas
import numpy as np
import matplotlib.pyplot as plt

# For prepending a header to the csv file
import fileinput
# Regular expression ans string manipulation
import re
# For navving/manipulating file system
import os

# Widgets
import progressbar as pb
from ipywidgets import widgets
from IPython.display import Javascript, display
# -----------------

# -----------------
# Pandas options
pandas.set_option('display.mpl_style', 'default') 
pandas.set_option('display.line_width', 500) 
pandas.set_option('display.max_columns', 60)
pandas.set_option('display.max_rows',10)
# -----------------

# ---INPUT WIDGET ---
cfile = widgets.Text(
    '/Users/ryoung/Documents/LabRotations/Sekuler/Data/outputPilot1.csv',
    description='Please provide CSV File:',
    border_radius='3px',
    color='darkred',
    font_size='9px',
    padding='1em',
    font_family='monospace',
    width='10000%'
)


# # Input CSV
# <a id="csvinput"></a>

# In[36]:

display(cfile)


# # Modify Muse CSV
# This step accomplishes two things. For one, it actually reduces the size of the csv by killing the spaces. Commas are the delimiters, so it has no effect expect to reduce file size. Second, our csvfile needs header names in the first row, to build a data frame.

# In[9]:

# OPEN FILE AND FIGURE OUT HOW MANY COLUMNS EXIST
with open(cfile.value,mode='r+') as file:
    
    def columnCount(line):
        l = line.split(',')
        return len(l)
    
    # Count columns
    nColumns = 0
    for line in file:
        curr_length = columnCount(line)
        #print("curr-> %d, max->%d" % (curr_length,nColumns))
        if curr_length > nColumns:
            nColumns = curr_length
    print("Number of columns = %d\n\n" % (nColumns))
    
    file.seek(0)
    lineone = file.readline()
    lineone = lineone.split(',')

if lineone[0] != "Timestamps":
    
    print('Fixing header with first line element %s\n\n'           % (lineone[0]))
    
    # Construct individual cxolumn headers
    column_names = ['Timestamps', 'Submod']
    nColumns-=2
    for c in range(int(nColumns)):
        column_names.append(str(c))
    print("List of elements to place atop ==> %s\n\n" % str(column_names))

    # Contruct the line to append
    header_string_to_write = "";
    for c in column_names:
        header_string_to_write += c + ","
    header_string_to_write = header_string_to_write[0:-1]
    
    # Prepend header to csv and kill any spaces (makes the file smaller and saves us pain below)
    for linenum,line in enumerate( fileinput.FileInput(cfile.value,inplace=1) ):
        if linenum is 0:
            print(header_string_to_write)
            print(line.rstrip())
        else:
            print( 
            re.sub(r'[\s]*',"", line.rstrip()) 
            )
    fileinput.close()
else:
    print('Header is good')

del(nColumns)


# ***

# # Data Scrub: Muse File
# 
# Below, a csv file is read in as a data frame. It's a flexible convenient object that will allow practically any data type encountered across csv rows with various amounts of columns. Subsequently, from the `pandas.DataFrame` object, we extract all the data into a nicer dictionary structure.
# 

# In[10]:

# Load csv into memory
D = pandas.read_csv(cfile.value,low_memory=True)
print("Memory Usage:\nMegabytes = %f\nGigabytes = %f"       % (D.memory_usage().sum()/1e6, D.memory_usage().sum()/1e9))
D


# Below, a graphic to show the shape of the data, if plot flag is on.
# 
# The image is a binary mask describing where data lives. **Black** indicates data lives there, **White** is void. The long black streaks are the fft packets. They appear to dump at irregular times.

# In[11]:

if plot_data_aspects:
    NullMat=D.isnull().as_matrix()
    mpl.pyplot.imshow(~NullMat, cmap='Greys',  interpolation='nearest', aspect='auto')


# ***

# ## Unique row components
# 
# There are currently 34 components dumped into the muse data

# In[12]:

# Acquire and print out all unique components
uniques = pandas.Series(D['Submod']).unique()
print('UNIQUE PACKET TYPES\n' + "-"*90)
for i,u in enumerate(uniques):
    print("(%d)\t%s" % (i,u))


# ## Helper Functions
# Some functions that will make our lives easier below

# In[13]:

def find_rightmost_empty(M):
    '''
    This method given a mxn matrix finds the rightmost column
    with an NaN value. This determines where for each packet type
    we stop our slicing.
    
    Input:    Numpy Matrix (hopefully cast into float, but may work with other types)
    Output:   Column number that NaNs begin the furthest from element 0 (furthest form the left)
    '''
    
    not_nan_M = ~np.isnan(M)
    (i,j) = np.nonzero(not_nan_M)
    #print('i elements %s' % str(i))
    #print('j elements %s' % str(j))
    return np.max(j)

def nestedAssignment(obj,addr,val):
    '''
    Deceptively simple method that takes a string list of keys and makes a nested assignment
    to the nested dictionary called obj = { { ... } } It finally plants the value at the end
    of the hiearachy of keys. It's able to be a few lines of code thanks to recursion and the
    "pass by reference" feature of the python language, different from matlab, which behaves
    like it passes by value ()
    '''
    if len(addr) > 1:
        
        key = addr.pop()

        try:
            test=obj[key]
        except KeyError:
            obj[key] = {}
        nestedAssignment(obj[key],addr,val)
    else:
        obj[addr.pop()] = val

def extract_into(into,at,what,rowtype):
    '''
    This method extracts rows containing `what` (string) from `frm` pandas object (using the Submod column).
    It then places the result into the dict `into`, at the location represented by `at`. `at` is a list.
    Each element, in order, is a key, indexing `into`
    
    Outputs: Modification of `into`, to include the `what` rows from `frm` pandas object's Submod, 
    '''
    global timestamp_zerod
    
    #Reverse order of at (I've set it up this way so that users can specifiy an address 'Raw','Data' in such
    # a way that Raw is the first index and data is the second. But my nestedAssignment method expects reverse
    # order because it treats the list as a stack using .pop() method)
    at = at[::-1]
    
    # Pick out the rows
    mask_rows = what['Submod'] == rowtype
    #print('Row type = %s' rowtype)
    #print("Sum of rows = %s, List = %s" % (str(mask_rows.sum()), str(mask_rows)))
    
    # Aquire data and associated timestamps
    data = what[mask_rows]
    del(data['Submod'])
    
    timestamps = data['Timestamps'].values
    timestamps = np.reshape(timestamps, (-1,1) )
    del(data['Timestamps'])
    if timestamp_zerod:
        timestamps = timestamps - timestamps[0]
    
    data = data.as_matrix().astype('float')
    # Now, cut out columns lacking data
    rightmost_col = find_rightmost_empty(data)
    data = data[:,:rightmost_col+1]
    
    data = np.concatenate( (timestamps,data), axis=1)
    
    # Now, we place the data into the dict
    at_copy = at.copy() # the method takes advantage of pass by reference, so wee need to copy this
    nestedAssignment(into,at,data)
    # Then, 
    #at_copy[0] += "_timestamps"
    #nestedAssignment(into,at_copy,timestamps)
    
    # Return dict, data, and timestamp for this type of data
    #return data,timestamps
    


# ## Data Structure Creation
# 
# Using those, we can create different organization systems. The most natural, I think, is a functional split, eeg versus behavioral. But sampling size split also might be nice.  
# 
# ### Functional Data Structure
# This structure groups things by how the data types are used and follow the following structure,
# `eeg` set containing `raw` components and `processed` components. Processed contains the **Muse** processed elements in the various frequency bands.
# 
# #### EEG

# In[26]:

# Our master structure to contain extracted data
eeg = {};


# Here, we place raw data and its timestamps into the `eeg` dictionary

# In[ ]:

# Place raw data
extract_into(eeg,['raw'],D,'/muse/eeg')


# A little extra processing to separate DRL and REF into separate elements. This is so that signal electrode portion remains robust to change. If last two columns are DRL and REF, and if in the future, if sets the option to not print them in muse (readable from /muse/config) to not write said signals in /eeg/raw, this will be rather easy to place an if statement below and electrode signals thusly always are under a separate key. Otherwise, I can forsee people hardcoding exclusions of the last two columns in downstream analysis, columns that might disappear depending on muse options.

# In[28]:

# Separate REF/DRL components into different terms
eeg['misc'] = {}
eeg['misc']['ref'] = eeg['raw'][:,-1]
eeg['misc']['drl'] = eeg['raw'][:,-2]
print(eeg['raw'].shape)
eeg['raw'] = np.delete(eeg['raw'], (-1), 1)
eeg['raw'] = np.delete(eeg['raw'], (-1), 1)
print(eeg['raw'].shape)


# In[30]:

# Show data, if option given
if plot_data_aspects:
    plt.figure(dpi=220,figsize = (12,6))

    ax = plt.subplot(3,1,1)
    plt.plot(eeg['raw'][:,0],eeg['raw'][:,1:],alpha=0.2)
    ax.set_xlabel('Seconds')
    ax.set_ylabel('uVolt')
    ax.set_title('Signal Electrodes')
    plt.legend(list(range(eeg['raw'][:,1:5].shape[0])))
    plt.subplot(3,1,2)
    plt.plot(eeg['raw'][:,0],eeg['misc']['drl'],alpha=0.2)
    ax=plt.subplot(3,1,3)
    plt.plot(eeg['raw'][:,0],eeg['misc']['ref'],alpha=0.2)
    ax.set_xlabel('Seconds')
    ax.set_ylabel('uVolt')
    ax.set_title('Reference Electrode')
    
    plt.tight_layout(pad=0.5)
    


# Now that raw data lives in the dictionary, we have relative and absolute signals that we can add to the dictionary.

# In[45]:

# Which fields to place into relatives and absolutes
relatives = [
    '/muse/elements/alpha_relative',
    '/muse/elements/beta_relative',
    '/muse/elements/delta_relative', 
    '/muse/elements/gamma_relative', 
    '/muse/elements/theta_relative',
]
absolutes = [
    '/muse/elements/alpha_absolute',
    '/muse/elements/beta_absolute',
    '/muse/elements/delta_absolute',
    '/muse/elements/gamma_absolute',
    '/muse/elements/theta_absolute',
    '/muse/elements/low_freqs_absolute'
]

# Set relatives into eeg dictionary
for elem in relatives:
    
    null,name = os.path.split(elem)
    name = re.sub(r'_relative','',name)
    
    extract_into(eeg,['rel',name],D,elem)

    

# Set absolutes into eeg dictionary
for elem in absolutes:
    
    null,name = os.path.split(elem)
    name = re.sub(r'_absolute','',name)
    
    extract_into(eeg,['abs',name],D,elem)


# Last, the FFT should go into the `eeg` dictionary

# In[46]:

# Prepare to store fft data
fft = [
    "/muse/elements/raw_fft0",
    "/muse/elements/raw_fft1",
    "/muse/elements/raw_fft2",
    "/muse/elements/raw_fft3"
]
# Carry out normal extraction of entries
for elem in fft:
    
    print(elem)
    
    null,name = os.path.split(elem)
    number = re.sub(r'raw_fft','',name)
    
    extract_into(eeg,['fft',number],D,elem)

fft = np.empty_like( eeg['fft'][ list(eeg['fft'].keys())[0] ]  )
# Post-process, where take all separate fft entries and combine them into a 3D array
#  Nsamples x (Ncomponents+1) x 
for key,val in eeg['fft'].items():
    fft = np.dstack((fft, eeg['fft'][key]))
    
eeg['fft'] = fft[:,:,1:]


# #### Behavior
# 
# First, create a behavior dictionary

# In[47]:

behavior = {}


# Then, place the headband signals int that dictionary

# In[48]:

headband = [
    "/muse/elements/touching_forehead",
    "/muse/elements/horseshoe",
    "/muse/elements/is_good"
]

for elem in headband:
    
    null,name = os.path.split(elem)
    name = re.sub(r'/muse/elements/','',name)
    
    extract_into(behavior,['headband',name],D,elem)


# And then, and finally, place muscle signals into behavior

# In[49]:

muscle = [
    "/muse/elements/blink",
    "/muse/elements/jaw_clench",
    "/muse/acc" # including accelorometer in the muscle signal dictionary/struct
]

for elem in muscle:
    
    null,name = os.path.split(elem)
    name = re.sub(r'/muse/elements/','',name)
    
    extract_into(behavior,['muscle',name],D,elem)


# #### Description
# Now that data are in place, here, a description field will be appended with descriptions of the data.

# In[50]:

# Appending descriptions for EEG dict
eeg['desc'] = {}
eeg['desc']['raw'] = "The first column indicate timestamps or time. The last two columns are DRL and REF signals that were used to reference the eeg signals present in columns 2 through end-2."
eeg['desc']['abs_all'] = "Fields for each absolute power band extracted by Muse. Absolute band power is log(sum(PSD)) of the absolute frequency range. Within each band type, indicated by the fields, the first column is the timestamp or time. Remaining columns are the power present per field."
eeg['desc']['rel_all'] = "Fields for each relative power band extracted by Muse. Relative power is gotten via first summing absolutes linear-power for a band by the sum of all linear-absolute power for all band types. Within each band type, indicated by the fields, the first column is the timestamp or time. Remaining columns are the power present per field."
eeg['fft'] = "Each page of this 3D matrix corresponds to an electrode. The first column is timestamp value. The remaining columns are fft values for that timestamp. As of this version, 129 columns with power, each 0.86hz per bin (220/256). Symmetric portion of the 256 sample removed, thus 128 bins. The last bin is 0Hz."
# Appending descriptions for the behavior dict
behavior['desc'] = {}


# # Data Scrub: Game File
# Last major series of operations concerns the game file, with its timestamped events. This will be considerably easier becasuse different data types do not live on different rows. They live on different columns--columns who do not change their meaning conditionally on the row.
# 
# ## Modify/Input Space-separated File

# In[9]:

# game_header = ["timeInSecs","eventType","gameId", "userId", "level", "age","mode", "gameTime",
#                    "lastBirth", "eventId", "visual", "audio", "side", "action", "actionTime",
#                    "RT", "keyValue", "correct", "congruent"]

# gamefile = re.sub(, cfile.value)
# with open()
# if lineone[0] != "Timestamps":
    
#     print('Fixing header with first line element %s\n\n' \
#           % (lineone[0]))
    
#     # Construct individual cxolumn headers
#     column_names = ['Timestamps', 'Submod']
#     nColumns-=2
#     for c in range(int(nColumns)):
#         column_names.append(str(c))
#     print("List of elements to place atop ==> %s\n\n" % str(column_names))

#     # Contruct the line to append
#     header_string_to_write = "";
#     for c in column_names:
#         header_string_to_write += c + ","
#     header_string_to_write = header_string_to_write[0:-1]
    
#     # Prepend header to csv and kill any spaces (makes the file smaller and saves us pain below)
#     for linenum,line in enumerate( fileinput.FileInput(cfile.value,inplace=1) ):
#         if linenum is 0:
#             print(header_string_to_write)
#             print(line.rstrip())
#         else:
#             print( 
#             re.sub(r'[\s]*',"", line.rstrip()) 
#             )
#     fileinput.close()
# else:
#     print('Header is good')

# del(nColumns)


# ## Bring into `pandas.DataFrame`

# ## Create `game` dict of `numpy` arrays 

# # Saving Data

# In[51]:

# Acquire base directory and file for all save options
dir,file = os.path.split(cfile.value)


# ## Matlab Native
# Matlab can read the pickled dictionaries above and pretty easily turn them into strings, but scipy offers a more native approach, packaing and reading from .mat files with ease.

# In[52]:

savestr = dir + '/' + file + '.structs.mat'
scipy.io.savemat( savestr, {'behavior':behavior, "eeg":eeg} )


# ## Python Native
# ### Data Frame

# In[53]:

if save_data_frame:
    file,ext = os.path.splitext(file)
    D.to_pickle(dir + '/' + file + '.pandas.pickle')


# ### EEG / Behavior Dictionaries

# In[54]:

behaviorstr = dir + '/' + file + '.behavior.pickle'
pickle.dump( behavior,  open(behaviorstr,  'wb'))


# In[56]:

eegstr = dir + '/' + file + '.eeg.pickle'
pickle.dump( eeg,       open(eegstr,       'wb'))

