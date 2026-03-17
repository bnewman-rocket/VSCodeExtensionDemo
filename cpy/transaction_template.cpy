	   01 header-record.
		 03 hdr-product-id pic x(15).
		 03 hdr-sep-1 pic x.
		 03 hdr-product-name pic x(48).
		 03 hdr-sep-2 pic x.
		 03 hdr-cost pic x(13).
		 03 hdr-sep-3 pic x.
		 03 hdr-quantity pic x(8).
		 03 hdr-sep-4 pic x.
		 03 hdr-total-cost pic x(13).
		 03 hdr-sep-5 pic x.
		 03 hdr-type pic x(4).
		 03 hdr-sep-6 pic x.
		 03 hdr-date pic x(8).
		 03 hdr-sep-7 pic x.
		 03 hdr-time pic x(8).

	   01 transaction-record.
		 03 trn-product-id pic x(15).
		 03 trn-sep-1 pic x.
		 03 trn-product-name pic x(48).
		 03 trn-sep-2 pic x.
		 03 trn-cost pic z(10).99.
		 03 trn-sep-3 pic x.
		 03 trn-quantity pic z(8).
		 03 trn-sep-4 pic x.
		 03 trn-total-cost pic z(10).99.
		 03 trn-sep-5 pic x.
		 03 trn-type pic x(4).
		   88 trn-bought value "Buy ".
		   88 trn-sold value "Sell".
		 03 trn-sep-6 pic x.
		 03 trn-timestamp.
		   05 trn-date pic 9(8).
		   05 trn-sep-7 pic x.
		   05 trn-time pic 9(8).