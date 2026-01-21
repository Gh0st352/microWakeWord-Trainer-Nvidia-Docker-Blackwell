# Training init failure plan (tf.keras.ops missing)

## Diagnosis
- The traceback shows `tf_keras.api._v2.keras` lacking `ops`, which means **legacy tf.keras** is being used instead of Keras 3. In TF 2.20 + Keras 3, `tf.keras.ops` exists; in legacy `tf_keras`, it does not.
- The most likely cause is `TF_USE_LEGACY_KERAS=1` (or similar) in the training environment.

## Plan (environment-level fix, no upstream patch)
1. **Force Keras 3 in training scripts** by explicitly disabling legacy tf.keras before any training starts.
   - Add `export TF_USE_LEGACY_KERAS=0` and/or `unset TF_USE_LEGACY_KERAS` near the existing TF env exports in:
     - [train_wake_word](train_wake_word:70)
     - [cli/wake_word_sample_trainer](cli/wake_word_sample_trainer:246)
   - Optionally set `export KERAS_BACKEND=tensorflow` alongside to avoid backend ambiguity for Keras 3.

2. **Document the requirement** in the troubleshooting section so users know legacy tf.keras must be disabled for mixednet training in this container.
   - Update [README.md](README.md:145) to mention `TF_USE_LEGACY_KERAS=0` if `tf.keras.ops` is missing.

## Validation
- Re-run training using the UI or `train_wake_word` and confirm the run proceeds past model creation without:
  - `AttributeError: module 'tf_keras.api._v2.keras' has no attribute 'ops'`
- Optional quick check inside the container:
  - `python - <<'PY'
import tensorflow as tf
print(hasattr(tf.keras, 'ops'))
PY`

## Files to touch
- [train_wake_word](train_wake_word:70)
- [cli/wake_word_sample_trainer](cli/wake_word_sample_trainer:246)
- [README.md](README.md:145)
