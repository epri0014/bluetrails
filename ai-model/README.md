# BlueTrails AI - Water Quality Prediction Model

This module contains deep learning models for predicting water quality parameters in Victorian marine environments using PyTorch.

## Overview

**Objective**: Predict five water quality parameters given site_id and future date:
- `CHL_A` (Chlorophyll A) - ug/L
- `Turb` (Turbidity) - NTU
- `DO_mg` (Dissolved Oxygen) - mg/L
- `N_TOTAL` (Total Nitrogen) - ug/L
- `Temperature` - degree C

**Input Features**:
- Site ID (categorical)
- Date (temporal)
- Engineered features from historical data

**Data Source**: EPA Victoria Water Quality Monitoring (1984-2024) stored in Supabase PostgreSQL database

## Folder Structure

```
ai-model/
├── notebook/
│   └── bluetrails_ai_*.ipynb    # Development notebook
├── model/                                    # Exported PyTorch models (.pth files)
└── README.md                                 # This file
```

## Model Development Approaches

We experiment with three feature engineering approaches:

### 1. Internal Model (Current Focus)
Uses only EPA dataset features. Potential engineered features:
- **Site encoding**: One-hot encoding, embeddings, or site statistics (lat/long, water body type)
- **Temporal features**: Month, season, day of year, year, cyclic encoding (sin/cos)
- **Historical statistics**: Rolling averages, lag features, trends per site
- **Site-specific patterns**: Mean/std/min/max per parameter per site

### 2. External Model (Future)
Incorporates external data sources:
- Weather data (temperature, rainfall, wind)
- Tidal information
- Ocean currents
- Seasonal environmental factors

### 3. Hybrid Model (Future)
Combines internal + external features for potentially best performance.

## Suggested PyTorch Model Architectures

### Option 1: Multi-Layer Perceptron (MLP) - Baseline
Simple feedforward network, good starting point:
```
Input → Dense(256) → ReLU → Dropout(0.3) →
        Dense(128) → ReLU → Dropout(0.3) →
        Dense(64) → ReLU →
        Output(5 parameters)
```

**Pros**: Fast training, interpretable, good baseline
**Cons**: May miss complex temporal patterns

### Option 2: LSTM/GRU Network - Sequential Patterns
Captures temporal dependencies using historical sequences:
```
Input Sequence → LSTM(128, 2 layers) → Dropout(0.3) →
                 Dense(64) → ReLU →
                 Output(5 parameters)
```

**Pros**: Captures time-series patterns, good for seasonal trends
**Cons**: Requires sequence data, slower training

### Option 3: Attention-Based Network - Advanced
Uses attention mechanism to focus on relevant features:
```
Input → Embedding (site) + Temporal Encoding →
        Multi-Head Attention →
        Dense(128) → ReLU → Dropout(0.3) →
        Dense(64) → ReLU →
        Output(5 parameters)
```

**Pros**: Flexible, can learn complex relationships
**Cons**: More complex, needs more data

### Option 4: Hybrid Architecture - Recommended Starting Point
Combines embeddings for categorical data with dense layers:
```
Site ID → Embedding(dim=32)  ┐
Temporal Features            ├→ Concatenate → Dense(256) → ReLU → Dropout(0.3) →
Historical Statistics        ┘                Dense(128) → ReLU → Dropout(0.2) →
                                              Dense(64) → ReLU →
                                              Output(5 parameters)
```

**Pros**: Handles mixed data types well, flexible
**Cons**: Moderate complexity

## Multi-Target Regression Strategy

Since we predict 5 parameters simultaneously:

1. **Single Model with 5 Outputs** (Recommended)
   - One model predicts all 5 parameters
   - Shared representations, faster training
   - Can capture parameter correlations

2. **Separate Models per Parameter**
   - 5 independent models
   - More parameters to tune
   - May be better if parameters are uncorrelated

## Training Strategy

- **Loss Function**: MSE (Mean Squared Error) or Huber Loss (robust to outliers)
- **Optimizer**: Adam with learning rate ~0.001
- **Regularization**: Dropout (0.2-0.4), L2 weight decay
- **Early Stopping**: Monitor validation loss, patience=10-20 epochs
- **Learning Rate Scheduling**: ReduceLROnPlateau or CosineAnnealing

## Evaluation Metrics

For regression models:
- **RMSE** (Root Mean Squared Error) - primary metric
- **MAE** (Mean Absolute Error) - interpretable error
- **R²** (R-squared) - variance explained
- **MAPE** (Mean Absolute Percentage Error) - relative error
- Per-parameter metrics to identify which predictions work best

## Database Schema Reference

Key tables and views:
- `v_epa_measurements_wide` - Wide format with all parameters
- `epa_site` - Site metadata (lat/long, water body)
- `epa_data` - Raw time series observations
- `v_epa_monthly_aggregates` - Pre-aggregated monthly stats

## Getting Started

1. Copy `.env.example` to `.env` and add Supabase credentials
2. Open `notebook/bluetrails_ai_water_quality.ipynb`
3. Install required packages (PyTorch, pandas, supabase-py, scikit-learn, matplotlib)
4. Follow notebook sections: Load → Preprocess → Train → Evaluate → Export

## Integration with Backend

Once trained, the best model will be:
1. Exported as `.pth` file to `model/` folder
2. Loaded by backend API for real-time predictions
3. Accessible via frontend through backend endpoints

## Notes

- Start with internal model to establish baseline
- Focus on proper train/validation/test split (70/15/15 or 80/10/10)
- Use proper scaling/normalization for features
- Handle missing values appropriately
- Consider temporal split (not random) to avoid data leakage
