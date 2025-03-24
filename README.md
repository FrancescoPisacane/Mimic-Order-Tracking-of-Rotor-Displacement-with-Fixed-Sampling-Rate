In many cases, the most cost-effective way to acquire data is through fixed-frequency sampling rather than using dedicated order-tracking hardware. However, this approach does not inherently provide data synchronized with rotational speed, making it challenging to analyze periodic phenomena in rotating machinery.
This script performs post-processing to reconstruct a displacement signal as a function of angular position, mimicking order tracking from uniformly sampled data. The workflow includes:

Calibration: Converting raw voltage signals into displacement using sensor sensitivity.

Peak Detection: Identifying trigger signal peaks to segment individual shaft revolutions.

Angular Speed Estimation: Computing the instantaneous rotational speed based on time differences between trigger peaks.

Low-Pass Filtering: Applying a Butterworth filter to remove high-frequency noise while preserving relevant motion dynamics.

Resampling by Angular Position: Interpolating each revolution onto a uniform angular grid to align signals across cycles.

Averaging Procedure: Combining multiple revolutions into a single averaged displacement profile, reducing noise and enhancing periodic features.


By leveraging these steps, the method allows order-tracking analysis even when the original acquisition was performed at a constant sampling rate, ensuring meaningful insights into the system’s vibrational behavior.
