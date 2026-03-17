       01 product-header.
         03 phdr-product-id pic x(9).
         03 phdr-sep-1 pic x.
         03 phdr-product-name pic x(12).
         03 phdr-sep-2 pic x.
         03 phdr-description pic x(11).
         03 phdr-sep-3 pic x.
         03 phdr-cost pic x(4).

       01 product-template. *> Total length 121
         03 product-id pic 9(9).
         03 product-name pic x(48).
         03 product-description pic x(64).
         03 product-cost pic 9(9).99.