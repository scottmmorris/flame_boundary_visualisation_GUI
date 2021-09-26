# Flame Boundary Visualisation GUI

MATLAB GUI to visualise the effect of changing image processing parameters on flame boundary detection in an optical engine

## Execution

Run the script from the command line using:

`Flame_Boundary_Visualisation_GUI`

or using the run button in the script editor menu (`f5`)

## Directory Customisation

At this stage, the path to the raw image files is not easily adjustable through the GUI and follows this convention:

`D:\scott\Documents\University\ResearchThesis\InjectionPressureVariation_202106\ProcessedMovie\50bar\f1_240_210_tSpk_6_S0001\f1_240_210_tSpk_6_S00010000`

In order to adjust the GUI to a custom directory the `DataDirectory` parameter must be changed within the code along with the `dataDir` function.
