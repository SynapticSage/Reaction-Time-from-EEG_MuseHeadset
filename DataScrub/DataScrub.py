
# coding: utf-8

# # MUSE CSV SCRUB
# 
#  Author | Ryan Y. 
# --------|--------
#  Point |  Takes the HUGE csv file and cuts it into separate data for the different submodules, then saving it both as pandas objects and then also to separate variables useable by matlab. |
# Inputs | File path to a Muse CSV File, <a href="#csvinput">type into widget below</a>|
# Outputs| A functional structure and sampling rate structures in formats readable by python and matlab |

# # Table of Contents
#  <p><div class="lev1 toc-item"><a href="#MUSE-CSV-SCRUB" data-toc-modified-id="MUSE-CSV-SCRUB-1"><span class="toc-item-num">1&nbsp;&nbsp;</span>MUSE CSV SCRUB</a></div><div class="lev2 toc-item"><a href="#Preamble" data-toc-modified-id="Preamble-1.1"><span class="toc-item-num">1.1&nbsp;&nbsp;</span>Preamble</a></div><div class="lev2 toc-item"><a href="#Input-CSV" data-toc-modified-id="Input-CSV-1.2"><span class="toc-item-num">1.2&nbsp;&nbsp;</span>Input CSV</a></div><div class="lev2 toc-item"><a href="#Generating-Column-Names" data-toc-modified-id="Generating-Column-Names-1.3"><span class="toc-item-num">1.3&nbsp;&nbsp;</span>Generating Column Names</a></div><div class="lev2 toc-item"><a href="#Set-display-options" data-toc-modified-id="Set-display-options-1.4"><span class="toc-item-num">1.4&nbsp;&nbsp;</span>Set display options</a></div><div class="lev2 toc-item"><a href="#Data-Manipulation" data-toc-modified-id="Data-Manipulation-1.5"><span class="toc-item-num">1.5&nbsp;&nbsp;</span>Data Manipulation</a></div><div class="lev3 toc-item"><a href="#Unique-row-components" data-toc-modified-id="Unique-row-components-1.5.1"><span class="toc-item-num">1.5.1&nbsp;&nbsp;</span>Unique row components</a></div><div class="lev3 toc-item"><a href="#Helper-Functions" data-toc-modified-id="Helper-Functions-1.5.2"><span class="toc-item-num">1.5.2&nbsp;&nbsp;</span>Helper Functions</a></div><div class="lev3 toc-item"><a href="#Data-Structure-Creation" data-toc-modified-id="Data-Structure-Creation-1.5.3"><span class="toc-item-num">1.5.3&nbsp;&nbsp;</span>Data Structure Creation</a></div><div class="lev4 toc-item"><a href="#(1)-Functional-Data-Structure" data-toc-modified-id="(1)-Functional-Data-Structure-1.5.3.1"><span class="toc-item-num">1.5.3.1&nbsp;&nbsp;</span>(1) Functional Data Structure</a></div><div class="lev2 toc-item"><a href="#Saving-Data" data-toc-modified-id="Saving-Data-1.6"><span class="toc-item-num">1.6&nbsp;&nbsp;</span>Saving Data</a></div>

# ***
# ***
# ***
# ***

# ## Preamble

# In[18]:

# --- FLAGS AND BASIC SETTINGS ----
from IPython import get_ipython

plot_data_aspects = False
# specify "inline" for inline graphs, "qt" for floating
#get_ipython().magic('matplotlib inline')
#get_ipython().magic('pylab inline')
#pylab.rcParams['figure.figsize'] = (14, 10)
save_directory = '~/Data/Sekuler/'
 
# -----IMPORTS ----
#Debugging
import pdb

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

# # ---INPUT WIDGET ---
# cfile = widgets.Text(
#     '/Users/ryoung/Documents/LabRotations/Sekuler/Data/outputPilot1.csv',
#     description='Please provide CSV File:',
#     border_radius='3px',
#     color='darkred',
#     font_size='10px',
#     padding='1em',
#     font_family='verdana',
#     width='10000%'
# )


# ## Input CSV
# <a id="csvinput"></a>

# In[4]:

#display(cfile)
class cfile:
    value = '/Users/ryoung/Documents/LabRotations/Sekuler/Data/outputPilot1.csv'



# ***
# ***
# ***
# ***

# ## Generating Column Names
# This step accomplishes two things. For one, it actually reduces the size of the csv by killing the spaces. Commas are the delimiters, so it has no effect expect to reduce file size. Second, our csvfile needs header names in the first row, to build a data frame.

# In[5]:

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


# ## Set display options
# 
# We setup display options in this section. This determines how much of pandas objects can potentially print to the screen.

# In[6]:

pandas.set_option('display.mpl_style', 'default') 
pandas.set_option('display.line_width', 5000) 
pandas.set_option('display.max_columns', 60)
pandas.set_option('display.max_rows',10)


# ***

# ## Data Manipulation
# 
# Below, a csv file is read in as a data frame. It's a flexible convenient object that will allow practically any data type encountered across csv rows with various amounts of columns. Subsequently, from the `pandas.DataFrame` object, we extract all the data into a nicer dictionary structure.
# 

# In[7]:

# Load csv into memory
D = pandas.read_csv(cfile.value,low_memory=True)
print("Memory Usage:\nMegabytes = %f\nGigabytes = %f"       % (D.memory_usage().sum()/1e6, D.memory_usage().sum()/1e9))
D


# Below, a graphic to show the shape of the data, if plot flag is on.
# 
# The image is a binary mask describing where data lives. **Black** indicates data lives there, **White** is void. The long black streaks are the fft packets. They appear to dump at irregular times.

# In[8]:

plot_data_aspects = False
if plot_data_aspects:
    NullMat=D.isnull().as_matrix()
    mpl.pyplot.imshow(~NullMat, cmap='Greys',  interpolation='nearest', aspect='auto')


# ***

# ### Unique row components
# 
# There are currently 34 components dumped into the muse data

# In[9]:

# Acquire and print out all unique components
uniques = pandas.Series(D['Submod']).unique()
print('UNIQUE PACKET TYPES\n' + "-"*90)
for i,u in enumerate(uniques):
    print("(%d)\t%s" % (i,u))


# ### Helper Functions
# Some functions that will make our lives easier below

# In[22]:

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
        if type(obj) is not type({}):
            pdb.set_trace()
            obj = {}
        pdb.set_trace()
        nestedAssignment(obj[addr.pop()],addr,val)
    else:
        pdb.set_trace()
        #print('Got here with len(addr) = %d and addr = %s with type %s' % (len(addr),addr,type(addr)))
        obj[addr.pop()] = val

def extract_into(into,at,what,rowtype):
    '''
    This method extracts rows containing `what` (string) from `frm` pandas object (using the Submod column).
    It then places the result into the dict `into`, at the location represented by `at`. `at` is a list.
    Each element, in order, is a key, indexing `into`
    
    Outputs: Modification of `into`, to include the `what` rows from `frm` pandas object's Submod, 
    '''
    
    # Pick out the rows
    mask_rows = what['Submod'] == rowtype
    
    # Aquire data and associated timestamps
    data = what[mask_rows]
    del(data['Submod'])
    timestamps = data['Timestamps'].values
    del(data['Timestamps'])
    data = data.as_matrix().astype('float')
    
    # Now, cut out columns lacking data
    rightmost_col = find_rightmost_empty(data)
    data = data[:,:rightmost_col+1]
    
    # Now, we place the data into the dict
    at_copy = at # the method takes advantage of pass by reference, so wee need to copy this
    nestedAssignment(into,at,data)
    # Then, 
    at_copy[0] += "_timestamps"
    nestedAssignment(into,at_copy,timestamps)
    
    # Return dict, data, and timestamp for this type of data
    return data,timestamps
    


# ### Data Structure Creation
# 
# Using those, we can create different organization systems. The most natural, I think, is a functional split, eeg versus behavioral. But sampling size split also might be nice.  
# 
# #### (1) Functional Data Structure
# This structure groups things by how the data types are used and follow the following structure,
# `eeg` set containing `raw` components and `processed` components. Processed contains the **Muse** processed elements in the various frequency bands.

# In[20]:

# Our master structure to contain extracted data
eeg = {};


# In[23]:

# Place raw data
#get_ipython().magic('debug')
print(extract_into(eeg,['Raw','Data'],D,'/muse/eeg'))


# In[ ]:

eeg


# In[9]:

# Let us obtain all the raw eeg records and timestamps
mask_eeg_rows = D['Submod'] == '/muse/eeg'

print( "EEG data constitutes %2.2f%% of packets\n" % ((mask_eeg_rows.sum() / D.index.size)*100) )

# Now that we have a mask of the all the eeg rows, lets get np arrays for the values and timestamps
raw = D[mask_eeg_rows]
del(raw['Submod'])
timestamps = raw['Timestamps'].values
del(raw['Timestamps'])
raw = raw.as_matrix().astype('float')
raw = raw[:,~np.isnan(raw).any(axis=0)] # slice out columns with electrode data


# In[10]:

eeg['raw'] = {}
eeg['raw']['data'] = raw
eeg['raw']['timestamps'] = timestamps


# In[11]:

if plot_data_aspects:
    plt.figure()
    plt.subplot(3,1,1)
    plt.plot(timestamps,raw[:,:4],alpha=0.2)
    plt.legend(list(range(raw[:,:4].shape[0])))
    plt.subplot(3,1,2)
    plt.plot(timestamps,raw[:,4:5],alpha=0.2)
    plt.subplot(3,1,3)
    plt.plot(timestamps,raw[:,5:],alpha=0.2)


# In[19]:

# Which fields to place into relatives and absolutes
relatives = [
    '/muse/elements/alpha_relative',
    '/muse/elements/beta_relative',
    '/muse/elements/delta_relative', 
    '/muse/elements/gamma_relative', 
    '/muse/elements/theta_relative',
]
absolutes = [
    '/muse/elements/low_freqs_absolute',
    '/muse/elements/alpha_absolute',
    '/muse/elements/beta_absolute',
    '/muse/elements/delta_absolute',
    '/muse/elements/gamma_absolute',
    '/muse/elements/theta_absolute'
]

# Create structures
eeg['rel'] = {}
for elem in relatives:
    
    null,name = os.path.split(elem)
    name = re.sub(r'_relative','',name)
    
    # Cut out proper rows; sieve timestaps and data
    X = D[D['Submod'] == elem]
    timestamps = X['Timestamps']
    #del(X['Timestamps'],X['Submod'])
    data = X.as_matrix().astype('float')
    data = data[:, ~np.isnan(data).any(axis=0)]
    
    # Remove the nan filled columns indicative of emptiness
    
    
for elem in absolutes:
    
    null,elem = os.path.split(elem)
    elem = re.sub(r'_absolute','',elem)
    


# In[20]:

X


# In[13]:

data = X.as_matrix().astype('float')
data


# In[14]:

slice= ~np.isnan(data)
slice = slice.any(axis=1)
slice


# In[16]:

get_ipython().magic('matplotlib qt')


# In[22]:

slice= ~np.isnan(data)
plt.clf()
plt.imshow( slice, aspect = "auto", cmap = "Greys", interpolation="None")


# ***
# ***
# ***
# ***
# ## Saving Data

# In[ ]:

dir,file = os.path.split(cfile.value)
file,ext = os.path.splitext(file)
D.to_pickle(dir + '/' + file + '.pandas.pickle')


# In[57]:

type({})

