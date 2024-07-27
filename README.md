
# Data Scrubber

This repository contains tools for preprocessing and analyzing EEG data alongside behavioral data. The primary tool is a data scrubber designed to clean and prepare data for analysis, specifically targeting reaction time data from an EEG-based video game experiment.

## Installation

To run the data scrubber, you need to install Jupyter and associated libraries. It is recommended to download the Python Anaconda distribution, which includes most of the necessary packages. You can find it on the [Anaconda website](https://www.anaconda.com/).

## Running the Data Scrubber

1. **Start Jupyter Notebook**:
   ```sh
   jupyter notebook DataScrub.ipynb
   ```
   This will open the Jupyter notebook in your web browser.

2. **Run All Cells**:
   If you do not need to modify the scrub file, you can run all cells by pressing `Ctrl+P` (or `Cmd+P` on Mac) and typing `run all cells` in the command search field.

3. **File Selection**:
   Select your CSV file containing the EEG data when prompted. The scrubber assumes that your game file has the same name but with a `.txt` extension. For example, if you select `Subject1.csv`, it will process `Subject1.txt` for the game data.

4. **Completion Check**:
   Ensure the final cell printed "Done". If it did not, this usually indicates a missing Python module. Check for error messages and install any missing modules using `conda` or `pip`.

## File Outputs

Three structs are provided after the data scrubbing process. Fields within each struct match the structure of the EEG, game, and behavioral data:

1. **eeg**: Fields separated by the type of EEG data. Includes a `config` field with extracted configuration information such as sampling rate and modes of operation.
2. **behavior**: Contains information about the muscle and headband signals.
3. **game**: Contains information about the game, e.g., when key presses are rendered, or the type of stimuli presented.

### Data Formats

The data are placed into terminal fields (fields that do not contain sub-fields) as follows:

- **Non-time-based data**: Single value, vector of values, or string.
- **Time-based data**: A `T x N` matrix where `T` is the number of time samples. The first column contains timestamps, followed by `N-1` columns of data.

### Advanced Data Modification

The data scrubber breaks down into four major sections:

1. **Preamble**
2. **Scrubbing Section for EEG Data**: Uses Pandas operations to create a DataFrame from the raw data.
3. **Scrubbing Section for Game Data**: Similar approach as the EEG data, but adapted for game data specifics.
4. **Save Section**: Saves the processed data into Python and Matlab compatible formats.

## Time Slicing and GLM Tools

### Time Slicing

The provided Matlab library includes tools to aid in the selection of time inclusion periods. These are useful when working with lists of data that do not share the same exact timestamps.

- **getTime**: Gets slices of time from nested struct of data.
- **applyTimes**: Applies a set of inclusion ranges to every piece of data within a struct.
- **unionTimes**: Merges inclusion ranges.
- **intersectTimes**: Intersects inclusion ranges.

### GLM Tools

- **cutSegments**: Cuts out data from the struct in special time ranges.
- **runGLM**: Runs a general linear model to predict a target sequence based on EEG and behavioral data.
- **combineSegments**: Combines data from multiple subjects for analysis.

## Reaction Time Data

The reaction time data used in the analysis comes from an EEG-based video game experiment. Subjects played a game that required quick responses to visual and auditory stimuli, and their reaction times were recorded for further analysis.

## Preliminary Results

Using the data scrubber and subsequent analysis tools, preliminary results (N=6) suggested - General linear models (GLM) applied to EEG data may predict a small piece of subject-level reaction times with more accuracy than chance. But more remains to be done on this front.

Examining linear model coefficients, frontal electrode beta band activity dominated reaction times prediction.

Predicting correct versus incorrect trial responses using EEG data remained challenging due to low error rates in the data set. Though this is not surprising, as correct/error often one of the hardest signals to pin down even with dense multi-electrode extracellular data.

The task involving audiovisual congruence revealed that reaction times are generally faster and more accurate when stimuli are congruent. This supports the hypothesis that multisensory integration plays a role in reaction time and accuracy.

## Data Outputs

Processed data can be saved in the following formats:

- **Pickle Files**: For Python/Numpy/Scipy analysis.
- **Matlab Files**: Separate structs for `eeg`, `behavior`, and `game`, or a master struct containing all sub-structs.

## License

This project is licensed under the MIT License. See the LICENSE file for details.


