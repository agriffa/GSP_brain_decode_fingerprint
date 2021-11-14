# GSP_brain_decode_fingerprint

Implementation of brain decoding, fingerprinting, and behavior multivariate correlation analysis from structure-function coupling data (Structural Decoupling Index (SDI), coupled-Functional Connectivity (c-FC), decoupled-Functional Connectivity (d-FC)) and functional data (functional connectivity (FC) nodal strength, FC), as described in:

> **Brain structure-function coupling provides signatures for task decoding and individual fingerprinting**  
> *Alessandra Griffa, Enrico Amico, Raphaël Liégeois, Dimitri Van De Ville, Maria Giulia Preti*  
> bioRxiv 2021.04.19.440314; doi: https://doi.org/10.1101/2021.04.19.440314


The SDI quantifies the degree of structure-function dependency for each brain region, and it has been defined in previous work:

> **Decoupling of brain function from structure reveals regional behavioral specialization in humans**  
> *Maria Giulia Preti, Dimitri Van De Ville*  
> Nature Communications 10, article number 4747 (2019); https://doi.org/10.1038/s41467-019-12765-7

The c-FC and d-FC represent a decomposition of the classical functional connectivity information into a component coupled with structure, and a component more decoupled from structure. The two components are obtained by low-pass (high-pass) filtering time-resolved fMRI brain signals with respect to the structural connectome harmonics.  


## Code implementation

GSP_brain_decode_fingerprint is a collection of **Matlab** scripts.


# Documentation

The documentation includes an [Installation guide](https://github.com/agriffa/GSP_brain_decode_fingerprint/main/Installation_guide.txt), [Instructions to run the code](https://github.com/agriffa/GSP_brain_decode_fingerprint/main/Instructions.txt), as well as [Software requirements](https://github.com/agriffa/GSP_brain_decode_fingerprint/main/Requirements.txt).

For questions, requesting assistance, suggesting enhancements or new ideas as well as for reporting bugs, please open an [issue](https://github.com/agriffa/GSP_brain_decode_fingerprint/issues).