# maposm 0.3.0

## refactor
The package has been refactored to use `osmextract` instead of `osmdata` for
data download and extraction. The `om_get()` function has gain some arguments
to deal with data download and update. 

## feat 
- add a new argument "force_download" to force the creation of the buildings 
layer on large areas


# maposm 0.2.0

## fix
- speed improvement with simpler buffers 
- better management of input and output CRSs
- increase request timeout and max memsize 
- increase maximum surface to allow building download
- better water body detection

## feat
- new map theme "pizza"
- add service roads and aeroways
