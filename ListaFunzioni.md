lista e descrizione delle funzioni. Tenere aggiornata, in modo da poterla poi copia-incollare nella documentazione

## C++ ##

  * `FindFeatures`: dato un set di immagini calcola lo spostamento delle features e ne salva le coordinate in un file di testo.

  * `iaasJoiningLine`: calcola in coordinate omogenee la retta passante per due punti.

## Matlab ##

  * `iaas`:

  * `fogLevel`: [DI FATTO NON USATA, CANCELLARE? ](.md) date le coordinate del punto di fuga calcola il livello della nebbia come il livello di grigio medio nell'intorno se questi è omogeneo.

  * `zoneHom`: restituisce il livello medio di grigio nell'intorno di una feature se questi è omogeneo.

  * `MichelsonContrast`: date le coordinate di una feature e la relative immagine restituisce il livello di contrasto nell'intorno come $$\frac{I_{max}-I_{min}}{I_{max}+I_{min}}$$

  * `rsmContrast`: date le coordinate di una feature e la relativa immagine calcola il livello di contrasto nell'intorno come $$\sqrt{\frac{1}{MN}\sum_{i=1}<sup>N\sum_{j=1}</sup>M(I_{ij}-\bar{I})^2}$$

  * `WeberContrast`: date le coordinate di una feature e la relative immagine calcola il livello di contrasto come $$\frac{I-I\_b}{I\_b}$$ dove $I\_b$ è il livello della nebbia.

  * `timeImpact`: date le coordinate del punto di fuga, di una feature in due differenti immagini e il relativo lasso tempo, stima il tempo mancante affinché la feature attraversi il piano focale.