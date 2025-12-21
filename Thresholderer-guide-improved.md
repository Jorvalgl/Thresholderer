# Thresholderer Macro Package: Complete User Guide

**Version**: Updated 2025  
**Resources**: [GitHub Repository](https://github.com/Jorvalgl/Thresholderer/) | [Video Tutorials] https://youtu.be/tFf33l93k5Q?si=DH50zinnxp6VD0q8](https://youtube.com/playlist?list=PLY8pqcDoek20LcpgHfIXGbwXdwmFEjg-i&si=AbwhopzAknmf3SNd

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites & Installation](#prerequisites--installation)
3. [Pre-Analysis Setup](#pre-analysis-setup)
4. [Folder Organization](#folder-organization)
5. [Running the Thresholderer Macro](#running-the-thresholderer-macro)
6. [Parameter Guide](#parameter-guide)
7. [Results Interpretation](#results-interpretation)
8. [Troubleshooting & Tips](#troubleshooting--tips)

---

## Overview

**Thresholderer** is a comprehensive ImageJ/FIJI macro package designed for **automated, high-throughput quantitative image analysis** across multiple threshold values. It enables researchers to analyze fluorescence microscopy images with batch processing capabilities, ROI-based analysis, and customizable filtering options.

### Key Features
- Batch processing of image stacks with multiple threshold values
- Background subtraction and noise filtering
- ROI (Region of Interest) support for targeted analysis
- Multi-channel analysis (up to 4 channels)
- Multiple measurement outputs (area, intensity, density metrics)
- Automated graphical output with statistical comparisons
- Support for confocal microscopy formats (LEICA .lif files)

---

## Prerequisites & Installation

### Requirements
- **FIJI/ImageJ** (free, open-source): Download from [fiji.sc](https://fiji.sc/)
- **Images**: 8-bit or 16-bit grayscale/multi-channel formats
  - **Supported formats**: TIFF, PNG, or TIF stacks
  - **LEICA confocal** users: First convert .lif files using the **Lif_series_separator** macro

### Installing Thresholderer
1. Download the macro package from [GitHub: Thresholderer](https://github.com/Jorvalgl/Thresholderer/)
2. Copy macro files to your FIJI/ImageJ `macros` folder:
   - Windows: `C:\Users\[YourName]\Fiji.app\macros\`
   - Mac: `/Applications/Fiji.app/macros/`
   - Linux: `~/Fiji.app/macros/`
3. Restart FIJI to register the macros
4. Access via: **Macros** menu → **Thresholderer**

---

## Pre-Analysis Setup

### Step 1: Image File Preparation

**Goal**: Each image/stack should be a single file (one image = one .tif file).

#### For LEICA Confocal Microscopy Users
If you have .lif files (LEICA Image File format):
1. Open your .lif file in FIJI
2. Run macro: **Macros** → **Lif_series_separator**
3. This will automatically export individual .tif files for each series

#### Image Format Specifications
- **Data type**: 8-bit or 16-bit (macro will convert to 8-bit if needed)
- **Stacks**: Z-stacks or time-series are supported
- **Naming**: Use consistent, descriptive names (e.g., `Animal1_Control_Z0xx.tif`)
- **Location**: Place all images in an **images folder** (see folder structure, Step 4)

---

### Step 2: Create Regions of Interest (ROIs) if Needed

**Purpose**: ROIs restrict analysis to specific anatomical regions or exclude artifacts.

#### Creating ROIs
- **Manual approach**: Use FIJI drawing tools (Rectangle, Circle, Polygon, etc.)
- **Automated approach**: Use the **ROIcreator** macro or compatible tools
- **Other tools**: Third-party ROI creation software compatible with ImageJ format

#### ROI Critical Requirements
⚠️ **IMPORTANT**: ROI filenames must exactly match image filenames (except extension)

**Example matching**:
```
Image:    Animal1_Control_Z001.tif
ROI:      Animal1_Control_Z001.zip  ✓ Correct
ROI:      Animal1_Control_Z001.roi   ✗ Wrong extension
ROI:      Animal1_Control.zip        ✗ Filename mismatch
```

#### Saving ROIs Correctly
1. Draw your ROI on an image
2. Save as: **File** → **Export** → **ROI** (saves as .zip with multiple ROIs)
3. Store in dedicated **ROIs folder** (see folder structure, Step 4)

---

### Step 3: Test Filters on Sample Images

Before processing your entire dataset, optimize your preprocessing filters on 2-3 representative images.

#### Filter Options Available

**A. Subtract Background Filter**
- **Function**: Removes uneven illumination and global background
- **Location in FIJI**: **Process** → **Subtract Background**
- **Algorithm**: Rolling ball algorithm
- **Best for**: Images with moderate, even background

**B. Difference of Gaussians (DoG) Filter**
- **Function**: Combines background subtraction with noise reduction (at non-zero min sigma)
- **Location in FIJI**: **Filters** → **Difference of Gaussians** (or use Dif_Gaussians_Jorge macro)
- **Parameters**:
  - **Min Sigma**: Determines noise reduction (higher value = more blur/smoothing)
  - **Max Sigma**: Controls background subtraction intensity (smaller value = stronger subtraction)
- **Best for**: Images with high noise and complex backgrounds

#### How to Optimize
1. Open a representative image
2. **Create duplicates** and test each filter independently
3. **Record successful parameters**:
   - Rolling ball radius (for Subtract Background)
   - Min and Max Sigma values (for DoG)
   - Order of application (DoG first vs. last)
4. **Visual assessment**: Compare original vs. filtered, looking for:
   - ✓ Structures of interest remain clear
   - ✓ Background is uniformly reduced
   - ✓ Noise is minimized
   - ✗ Signal is not lost

#### Example Workflow
```
Original Image
  ↓ (Apply DoG: Min Sigma = 1, Max Sigma = 4)
Filtered Image A
  ↓ (Apply Subtract Background: Radius = 50)
Filtered Image B (optimal) → Use these parameters
```

---

## Folder Organization

### Hierarchical Structure

The Thresholderer macro requires a specific folder hierarchy to organize different experimental groups and biological replicates. This structure enables batch analysis while maintaining proper statistical grouping.

```
ProjectFolder/ (General Folder - specify this to the macro)
│
├── ControlGroup/ (Group 1 - experimental condition)
│   ├── Animal1/ (Replica 1)
│   │   ├── images/ (all images for this replica)
│   │   │   ├── image1.tif
│   │   │   ├── image2.tif
│   │   │   └── image3.tif
│   │   └── ROIs/ (optional - ROI .zip files)
│   │       ├── image1.zip
│   │       ├── image2.zip
│   │       └── image3.zip
│   ├── Animal2/ (Replica 2)
│   │   ├── images/
│   │   │   ├── image1.tif
│   │   │   └── ...
│   │   └── ROIs/
│   └── Animal3/ (Replica 3)
│
└── ExperimentalGroup/ (Group 2 - different condition)
    ├── Animal1/
    │   ├── images/
    │   └── ROIs/
    ├── Animal2/
    └── Animal3/
```

### Key Points

| Level | Purpose | Example |
|-------|---------|---------|
| **General Folder** | Root directory containing all experiments | `MyProject_2025/` |
| **Group Folders** | Experimental conditions being compared | `Control`, `Treated`, `Knockout` |
| **Replica Folders** | Individual biological replicates (n) | `Animal1`, `Subject_n2`, `A`, `B`, `C` |
| **Images Folder** | Contains analysis images (required) | Must be named `images` |
| **ROIs Folder** | Contains ROI .zip files (optional) | Must be named `ROIs` if used |

### Naming Conventions (Recommended)

```
✓ Clear: Control_Animal1, Treated_Mouse3, WT_Sample_A
✗ Unclear: G1, Sample, Data123

✓ Consistent: images/ (lowercase, plural)
✗ Inconsistent: Images/, image_files/, IMG/
```

---

## Running the Thresholderer Macro

### Launching the Macro

1. Open FIJI
2. Navigate to: **Macros** → **Thresholderer**
3. The **MULTI THRESHOLD DIALOG** box will appear
4. Configure parameters as described in the following section
5. Click **OK** to begin processing

---

## Parameter Guide

### General Settings

#### See Images While Running
- **When to check**: During optimization/first analysis of new data
- **When to uncheck**: For batch processing large datasets (speeds up analysis)
- **Behavior**: Displays each processed image in real-time

#### Images Folder Name
- **What to enter**: The exact name of your images directory
- **Example**: Type `images` (this is the folder containing your .tif files within each replica directory)
- **Important**: Must match folder name exactly (case-sensitive on some systems)

#### Convert to 8 bits
- **When to check**: 
  - If working with 16-bit images (confocal microscopy)
  - If ImageJ indicates a conversion warning
- **When to uncheck**: If images are already 8-bit
- **Effect**: Converts to 8-bit grayscale, which may compress intensity information but accelerates processing

#### All Slices
- **When to check**: You want to analyze every Z-slice or timepoint in your stack
- **When to uncheck**: You want to manually specify a subset of slices (see "Slice and Channel Selection")

---

### Slice and Channel Selection

**Purpose**: Analyze specific slices from multi-slice stacks or specific fluorescence channels.

#### Initial Slice / Final Slice
- **When to use**: Your stack has multiple slices but you want to analyze only a subset
- **Example**: A Z-stack has 30 slices; analyze only slices 5–20 (skipping top/bottom defocus regions)
- **Note**: Requires "All Slices" to be **unchecked**

#### Channel
- **Options**: 1, 2, 3, or 4
- **When to specify**: Multi-channel images (e.g., DAPI + GFP + RFP)
- **Example**: Enter `2` to analyze only the GFP channel
- **Note**: FIJI uses 1-indexed channels (first channel = 1, not 0)

---

### Filtering and Background Correction

#### Remove Outliers
- **Function**: Removes single-pixel noise (salt-and-pepper noise)
- **Algorithm**: ImageJ's "Remove Outliers" tool
- **When to enable**:
  - ✓ High-frequency noise (speckled appearance)
  - ✓ After scanning confocal images
  - ✗ Low signal-to-noise images (may remove true signal)

| Parameter | Role | Typical Value |
|-----------|------|---------------|
| **Radius** | Size of noise speckles to remove (pixels) | 1–3 |
| **Threshold** | Intensity difference to classify as outlier | 50–100 |

**Reference**: [ImageJ Remove Outliers Documentation](https://imagej.net/ij/docs/menus/process.html)

#### Subtract Background
- **Function**: Removes uneven illumination using a rolling ball algorithm
- **When to enable**: 
  - ✓ Uneven background across image
  - ✓ Bright edges or vignetting
  - ✗ Already well-corrected images

| Parameter | Role | Typical Value | Range |
|-----------|------|--------------|-------|
| **Rolling Ball Radius** | Size of the "ball" for background estimation (pixels) | 30–100 | 1–500 |

**Interpretation**: Larger radius = assumes background varies over larger distances

**Reference**: [ImageJ Subtract Background Documentation](https://imagejdocu.list.lu/gui/process/subtract_background)

#### Difference of Gaussians (DoG)
- **Function**: Combines edge enhancement with noise reduction
- **When to enable**: 
  - ✓ Images with complex backgrounds and noise
  - ✓ When noise reduction is critical
  - ✗ Already clean, high-contrast images

| Parameter | Role | Effect Range |
|-----------|------|--------------|
| **Min Sigma** | Noise suppression blur amount | Higher = more blur, better noise reduction |
| **Max Sigma** | Background subtraction strength | Smaller = stronger subtraction |

**Interpretation Example**:
```
Min Sigma = 0.5:  Minimal blur (preserves detail but less noise reduction)
Min Sigma = 1.0:  Moderate blur
Min Sigma = 5.0:  Heavy blur (removes noise but may obscure fine structures)

Max Sigma = 5:   Very aggressive background subtraction
Max Sigma = 20:  Strong background subtraction
Max Sigma = 50:  Weak background subtraction
```

#### Dif. of Gaussians First?
- **Check this if**: You want DoG applied before Subtract Background
- **Uncheck if**: You want Subtract Background applied first
- **Recommendation**: Test both orders on sample images; effects vary by image type

---

### Regions of Interest (ROIs)

#### Use ROIs
- **Check if**: You have ROI .zip files and want to restrict analysis to specific regions
- **Uncheck if**: You want to analyze the entire image

#### Line ROI
- **Check if**: Your ROIs are linear (e.g., line scans, axons)
- **Uncheck if**: Your ROIs are areas (e.g., circles, polygons, irregular regions)

#### Name of ROIs Folder
- **What to enter**: Exact folder name containing your .zip files
- **Default**: `ROIs`
- **Requirement**: Must match the folder name exactly

#### Info of Each Single ROI
- **Check if**: You want separate result tables for each individual ROI
- **Uncheck if**: You want only aggregated results across all ROIs

**Example Output**:
```
With "Info of each single ROI" checked:
  Results_ROI1.csv
  Results_ROI2.csv
  Results_ROI3.csv
  Results_Combined.csv

Unchecked:
  Results_Combined.csv (only)
```

#### Preserve ROIs Stack Positions
- **Check if**: ROIs correspond to specific slices (e.g., slice 5 ROI applies only to slice 5)
- **Uncheck if**: The same ROIs should be applied to all slices in the stack

**Example Use Case**:
```
Z-stack with 20 slices
Slice 7 has anatomical landmark → ROI created for slice 7

Checked:    ROI applied only to slice 7 ✓
Unchecked:  ROI applied to all 20 slices ✗
```

#### Invert ROIs
- **Check if**: You want to analyze everything **outside** the ROI region
- **Uncheck for**: Standard analysis (everything **inside** the ROI)

**Use Cases**:
```
Standard ROI:    Measure signal in cell nucleus
Inverted ROI:    Measure signal in cytoplasm (everything outside nucleus)
```

---

### Thresholding Parameters

**Purpose**: The macro tests multiple threshold values to identify the optimal threshold for your data.

#### Initial Threshold
- **Definition**: The lowest threshold value to test
- **Typical range**: 10–50 (for 8-bit images: 0–255)
- **Consideration**: Should be above background noise level

#### Last Threshold
- **Definition**: The highest threshold value to test
- **Typical range**: 100–200 (for 8-bit images: 0–255)
- **Consideration**: Should not exceed expected signal intensity

#### Threshold Step
- **Definition**: Increment between successive threshold tests
- **Example**: Initial=50, Step=10, Last=150 → tests 50, 60, 70, ..., 150
- **Trade-off**:
  - Smaller step (5): More data points, finer resolution, **longer analysis time**
  - Larger step (20): Fewer data points, faster, **may miss inflection points**

**Visualization**:
```
Initial: 50, Last: 150, Step: 10 (11 threshold values tested)
Threshold values: 50 → 60 → 70 → 80 → 90 → 100 → 110 → 120 → 130 → 140 → 150
                  ├──────────────────── Analysis Range ────────────────┤
```

---

### Measurements

**Purpose**: Select which quantitative parameters to extract from thresholded images.

#### Output Metrics Explained

| Metric | Definition | Use Case |
|--------|-----------|----------|
| **Area Fraction (%)** | Percentage of pixels above threshold | Overall staining density |
| **Mean Intensity** | Average gray value in thresholded area | Signal brightness |
| **Integrated Density** | Sum of all pixel values (area × intensity) | Total signal |
| **Integrated Density / Total Area** | Integrated density ÷ total image area | Normalized signal density |
| **RawIntDensity** | Sum of unprocessed pixel values | Raw signal without normalization |
| **RawIntDensity / Total Pixels** | Raw signal ÷ total pixels | Pixel-by-pixel average intensity |

#### Practical Selection Guide

**For Most Applications (Recommended)**:
- ✓ Area Fraction (primary metric)
- ✓ Integrated Density (secondary metric)

**For Detailed Analysis**:
- ✓ All above
- ✓ Mean Intensity (assess brightness independently of area)

**Default Behavior**: If no measurements are selected, Area Fraction is analyzed automatically.

#### Invert Image
- **Check if**: Analyzing dark staining on light background (e.g., dark blue DAB, dark purple staining)
- **Uncheck for**: Light structures on dark background (standard fluorescence)

**Visual Logic**:
```
Standard (unchecked):     Dark background, bright signal → threshold bright
Inverted (checked):       Bright background, dark signal → inverts, then thresholds bright
```

---

## Results Interpretation

### Output Organization

After analysis completes, the macro creates a **results folder** containing:

```
Results_[ProjectName]/
├── Group1_graphs/
│   ├── Group1_AreaFraction.tif       (graph image)
│   ├── Group1_MeanIntensity.tif
│   └── ...
├── Group2_graphs/
│   └── (similar structure)
├── Combined_AreaFraction.csv         (data tables)
├── Combined_MeanIntensity.csv
├── Statistical_Summary.txt           (if available)
└── threshold_values_tested.txt       (parameters used)
```

### Graph Interpretation

#### Area Fraction Graphs (Most Important)

**What it shows**: Percentage of image area above threshold at each tested threshold level.


#### Key Features to Look For

1. **Inflection Point**: Where the curve changes slope most dramatically
   - This often indicates the true "transition" from background to signal
   - Optimal threshold for comparison across images

2. **Group Separation**: Curves for different experimental groups should diverge
   - At some threshold range, treated vs. control should show clear differences
   - Suggests meaningful quantitative differences


#### Decision Strategy

**Step 1**: Visually identify the inflection point on the Area Fraction graph

**Step 2**: At that threshold region:
- Manually threshold 2–3 representative images
- Visually inspect the binary result (black/white image)
- Verify that signal of interest is captured, not background

**Step 3**: Compare curves across groups:
- Do groups show expected differences at certain thresholds?
- Is the separation biologically meaningful?

**Step 4**: Confirm your chosen threshold by:
- Checking results at ±5–10 threshold values
- Ensuring robustness (results shouldn't change dramatically with small threshold shifts)

---

## Troubleshooting & Tips

### Common Issues and Solutions

#### Issue 1: Macro Cannot Find Image Folder
**Symptom**: Error message "Could not find images folder"

**Causes & Solutions**:
- ❌ Folder name mismatch (entered "Images" but folder is "images")
  - ✓ **Solution**: Match case exactly; FIJI is case-sensitive on Mac/Linux
- ❌ Images folder is not a subdirectory of replica folders
  - ✓ **Solution**: Restructure: `Animal1/images/` not `Animal1/raw_data/images/`
- ❌ ROI folder structure incorrect when ROIs are used
  - ✓ **Solution**: Create `ROIs/` at same level as `images/`

#### Issue 2: ROIs Not Applied to Images
**Symptom**: Analysis runs but seems to ignore ROIs

**Causes & Solutions**:
- ❌ ROI filenames don't match image filenames exactly
  - ✓ **Solution**: Image `sample1.tif` needs ROI named `sample1.zip` (not `sample1_ROI.zip`)
- ❌ ROIs are saved as `.roi` files instead of `.zip`
  - ✓ **Solution**: Use FIJI File → Export → ROI (creates .zip) not "Save ROI"
- ❌ "Use ROIs" checkbox is unchecked
  - ✓ **Solution**: Check the "Use ROIs" option in the dialog

#### Issue 3: Filtering Removes All Signal
**Symptom**: Filtered images appear blank or nearly black

**Causes & Solutions**:
- ❌ Subtract Background radius too large
  - ✓ **Solution**: Start with smaller radius (20–30) and increase if needed
- ❌ DoG Max Sigma value too small (overaggressive background removal)
  - ✓ **Solution**: Increase Max Sigma value (try 3–5)
- ❌ Multiple filters applied sequentially removing cumulative signal
  - ✓ **Solution**: Test filters individually first; don't combine both by default

#### Issue 4: Results Show No Differences Between Groups
**Symptom**: Graphs are nearly identical despite expected biological differences

**Causes & Solutions**:
- ❌ Threshold range doesn't capture the relevant differences
  - ✓ **Solution**: Expand Initial and Last Threshold values
- ❌ Filters too aggressive, removing subtle differences
  - ✓ **Solution**: Reduce filter strength or test without filters
- ❌ ROIs excluding relevant regions of interest
  - ✓ **Solution**: Verify ROI placement visually; re-create if necessary
- ❌ Insufficient statistical power (too few replicas)
  - ✓ **Solution**: Increase sample size (n) if possible

#### Issue 5: Analysis Is Too Slow
**Symptom**: Processing large datasets takes many hours

**Optimization Tips**:
- ✓ Uncheck "See images while running"
- ✓ Increase Threshold Step value (test fewer threshold values)
- ✓ Reduce image size (downsampling if appropriate)
- ✓ Use 8-bit images (convert from 16-bit if available)
- ✓ Process subsets of data separately

#### Issue 6: FIJI Crashes During Analysis
**Symptom**: FIJI closes unexpectedly or becomes unresponsive

**Prevention**:
- ✓ Increase FIJI memory allocation:
  - Edit: **Edit → Preferences → Memory & Threads**
  - Allocate 70–80% of available system RAM
- ✓ Reduce batch size (process fewer images at once)
- ✓ Close other applications to free system memory
- ✓ Restart FIJI between large batch analyses

---

### Best Practices for Optimal Results

#### Before Running Analysis
1. **Validate folder structure** on 1–2 samples before full batch
2. **Test filters** on 3–5 representative images
3. **Verify ROI matching** if using ROIs (check filenames)
4. **Document your parameters** in a text file for reproducibility

#### During Analysis
5. **Run on a dedicated computer** if processing large datasets
6. **Monitor early results** by keeping "See images" checked for first run
7. **Save your parameter settings** (screenshot or log file)

#### After Analysis
8. **Check Area Fraction graph first** — this is your primary result
9. **Visually verify** 2–3 thresholded images at your chosen threshold
10. **Compare across biological replicates** (not just group means)
11. **Test robustness**: Do conclusions change if you shift threshold ±10?

---

### Video Tutorial Reference

Comprehensive video tutorials are available:
- **Main tutorial**: [Thresholderer YouTube Series](https://youtu.be/tFf33l93k5Q?si=DH50zinnxp6VD0q8)
- **Topics covered**: Setup, parameter optimization, results interpretation, troubleshooting

---

## Technical References

### ImageJ/FIJI Tools Used by Thresholderer
- Remove Outliers: [Documentation](https://imagej.net/ij/docs/menus/process.html)
- Subtract Background: [Documentation](https://imagejdocu.list.lu/gui/process/subtract_background)
- Particle Analysis: Built-in FIJI function
- ROI Manager: Built-in FIJI function

### Related Macros in the Package
- **Lif_series_separator**: Converts LEICA .lif files to individual .tif images
- **ROIcreator**: Creates ROIs from image features (if available)
- **Dif_Gaussians_Jorge**: Specialized DoG filter implementation

### Recommended Reading
- Pete Bankhead's ImageJ Guide: [Measurements & ROIs](https://petebankhead.gitbooks.io/imagej-intro/content/chapters/rois/rois.html)
- Current Protocols: Basic Image Analysis in ImageJ/Fiji

---

## Summary Checklist

Before running Thresholderer, ensure you have:

- [ ] FIJI installed with Thresholderer macros
- [ ] Images in 8-bit or 16-bit TIFF format (.tif)
- [ ] Folder structure: **ProjectFolder → GroupFolders → ReplicaFolders → images/ (and ROIs/ if applicable)**
- [ ] Tested Subtract Background and/or DoG filters on 2–3 sample images
- [ ] Documented filter parameters (rolling ball radius, Min/Max Sigma values)
- [ ] ROI filenames exactly match image filenames (if using ROIs)
- [ ] Reasonable threshold range (Initial, Last, Step values)
- [ ] Measurement types selected (at minimum: Area Fraction)
- [ ] Backup of original data

---

## Support & Resources

| Resource | Link |
|----------|------|
| **GitHub Repository** | https://github.com/Jorvalgl/Thresholderer/ |
| **Video Tutorials** | https://youtu.be/tFf33l93k5Q?si=DH50zinnxp6VD0q8](https://youtube.com/playlist?list=PLY8pqcDoek20LcpgHfIXGbwXdwmFEjg-i&si=AbwhopzAknmf3SNd|
| **FIJI Download** | https://fiji.sc/ |
| **ImageJ Documentation** | https://imagej.net/ |

---

**Last Updated**: December 2025  
**Guide Version**: 2.0 (Enhanced)  
**Feedback**: For issues or suggestions, please visit the GitHub repository.
