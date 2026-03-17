       identification division.
       program-id. BuySellERP.

       author. Ben Newman

       *> This is a comment

       environment division.
       input-output section.
       file-control.
           select transaction-log
               assign to dynamic ws-log-filename
               organization is line sequential.
           select products
               assign to "products.dat"
               organization is line sequential.
           select inventory
               assign to "inventory.dat"
               organization is line sequential.

       data division.
       file section.
       fd products.
       copy "cpy/products_template.cpy".

       fd inventory.
       copy "cpy/inventory_template.cpy".

       fd transaction-log.
       copy "cpy/transaction_template.cpy".

       working-storage section.
       01 ws-log-date pic 9(8).
       01 ws-log-time pic 9(8).
       01 ws-log-filename pic x(100).
       01 ws-trn-count pic 9(4) value 4.
       01 ws-index pic 9(4) value 1.

       01 max-product-id pic s9(9) comp-5 value 0.

       01 ws-product-found pic x value "N".
         88 product-found value "Y".
         88 product-not-found value "N".
       01 ws-product-id pic 9(9) value 0.
       01 ws-product-name pic x(48) value spaces.
       01 ws-product-description pic x(64) value spaces.
       01 ws-product-cost pic s9(9)v99 value 0 comp-5.
       01 ws-total-cost pic s9(9)v99 value 0 comp-5.

       01 ws-inv-count pic 9(4) value 0.
       01 ws-inv-index pic 9(4) value 0.
       01 ws-inv-delta pic s9(9) comp-5 value 0.
       01 ws-inventory-table occurs 100 times.
         03 ws-inv-product-id pic 9(9).
         03 ws-inv-quantity pic s9(9) comp-5.

       01 purchase-record occurs 100 times.
         copy "cpy/purchase-template.cpy".
       01 purchase-record-id pic s9(9) comp-5 value 1.

       01 user-input pic x value " ".
         88 quit value "Q", "q".
         88 ptl value "P", "p".
         88 ap value "A", "a".
         88 vp value "V", "v".
         88 vi value "I", "i".
         88 b value "B", "b".
         88 s value "S", "s".

       procedure division.

           perform until quit
               perform print-options
               if ptl
                   perform print-transaction-log
               end-if
               if ap
                   perform add-new-product
               end-if
               if vp
                   perform view-products
               end-if
               if vi
                   perform view-inventory
               end-if
               if b
                   perform buy-product
               end-if
               if s
                   perform sell-product
               end-if
           end-perform

           stop run
           .

       print-options section.
           display "---------------------------------"
           display "Options:"
           display " - Add New Product         (A, a)"
           display " - View Products           (V, v)"
           display " - View Inventory          (I, i)"
           display " - Buy Product             (B, b)"
           display " - Sell Product            (S, s)"
           display " - Print Transaction Log   (P, p)"
           display " - Quit                    (Q, q)"
           accept user-input
           .

       print-transaction-log section.
           display "Printing Transaction Log"
           accept ws-log-date from date yyyymmdd
           accept ws-log-time from time
           string
             "Transactions/" delimited by size
             ws-log-date delimited by size
             "_" delimited by size
             ws-log-time delimited by size
             ".txt" delimited by size
             into ws-log-filename
           end-string

           open output transaction-log

           perform write-header
           perform set-seperators

           declare i as binary-long = 1
           perform varying i from 1 by 1 until i > purchase-record-id -
             1
               perform write-transaction(i)
           end-perform

      *    display ws-log-time
           move 1 to purchase-record-id

           close transaction-log
           .

       add-new-product section.
           display "Adding new product to database"

           display "Existing Products:"
           perform view-products

           open extend products

           add 1 to max-product-id
           move max-product-id to product-id

           display "Enter a new Product Name: "
           accept product-name
           display "Enter a Product Description: "
           accept product-description
           display "Enter the Product Cost: "
           accept product-cost
           write product-template
           close products
           .

       view-products section.
           move 0 to max-product-id
           move "PROD_ID" to phdr-product-id
           move "PRODUCT_NAME" to phdr-product-name
           move "DESCRIPTION" to phdr-description
           move "COST" to phdr-cost
           move "|" to phdr-sep-1 phdr-sep-2 phdr-sep-3
           display product-header

           open input products
           declare eof as binary-char = 0
           perform until eof = 1
               read products
                   at end
                       move 1 to eof
                   not at end
                       *> process the product record here
                       display
                         product-id "|"
                         function trim (product-name) "|"
                         function trim (product-description) "|"
                         product-cost
                       add 1 to max-product-id
               end-read
      *        display product-name
           end-perform
           close products
           .

       view-inventory section.
           move "PROD_ID" to ihdr-product-id
           move "QUANTITY" to ihdr-quantity
           move "|" to ihdr-sep-1
           display inventory-header

           open input inventory
           declare eof as binary-char = 0
           perform until eof = 1
               read inventory
                   at end
                       move 1 to eof
                   not at end
                       *> process the inventory record here
                       display
                         inv-product-id "|"
                         inv-quantity
               end-read
      *        display product-name
           end-perform
           close inventory
           .

       buy-product section.
           display "Buying a product" purchase-record-id
           display "Available Products:"
           perform view-products
           display "Enter the Product ID to buy: "
           accept buy-product-id(purchase-record-id)
           display "Enter the quantity to buy: "
           accept buy-quantity(purchase-record-id)
           move "Buy " to buy-type(purchase-record-id)
           move buy-quantity(purchase-record-id) to ws-inv-delta
           perform update-inventory(buy-product-id(purchase-record-id)
               ws-inv-delta)
           add 1 to purchase-record-id
           .

       sell-product section.
           display "Selling a product"
           display "Available Products:"
           perform view-inventory
           display "Enter the Product ID to sell: "
           accept buy-product-id(purchase-record-id)
           display "Enter the quantity to sell: "
           accept buy-quantity(purchase-record-id)
           move "Sell" to buy-type(purchase-record-id)
           compute ws-inv-delta = 0 - buy-quantity(purchase-record-id)
           perform update-inventory(buy-product-id(purchase-record-id)
               ws-inv-delta)
           add 1 to purchase-record-id
           .

       write-header section.
           move "|" to hdr-sep-1 hdr-sep-2 hdr-sep-3 hdr-sep-4 hdr-sep-5
             hdr-sep-6 hdr-sep-7
           move "PRODUCT_ID" to hdr-product-id
           move "PRODUCT_NAME" to hdr-product-name
           move "COST" to hdr-cost
           move "QUANTITY" to hdr-quantity
           move "TOTAL_COST" to hdr-total-cost
           move "TYPE" to hdr-type
           move "DATE" to hdr-date
           move "TIME" to hdr-time
           write header-record
           .

       set-seperators section.
           move "|" to trn-sep-1 trn-sep-2 trn-sep-3 trn-sep-4 trn-sep-5
             trn-sep-6 trn-sep-7
           .

       write-transaction section (t-prod-id as binary-long).
           display "PROD_ID: " buy-product-id(t-prod-id)
             " QUANTITY: " buy-quantity(t-prod-id)
           move ws-log-date to trn-date
           move ws-log-time to trn-time
           move buy-product-id(t-prod-id) to trn-product-id
           perform get-product-details(buy-product-id(t-prod-id))
           if product-found
               move ws-product-name to trn-product-name
               move ws-product-cost to trn-cost
           else
               move "UNKNOWN" to trn-product-name
               move 0 to trn-cost
           end-if
           move buy-quantity(t-prod-id) to trn-quantity
           compute ws-total-cost = ws-product-cost *
             buy-quantity(t-prod-id)
           move ws-total-cost to trn-total-cost
           move buy-type(t-prod-id) to trn-type
           write transaction-record
           .

       load-inventory section.
           move 0 to ws-inv-count
           open input inventory
           declare eof as binary-char = 0
           perform until eof = 1
               read inventory
                   at end
                       move 1 to eof
                   not at end
                       add 1 to ws-inv-count
                       move inv-product-id to
                         ws-inv-product-id(ws-inv-count)
                       move inv-quantity to
                         ws-inv-quantity(ws-inv-count)
               end-read
           end-perform
           close inventory
           .

       save-inventory section.
           open output inventory
           declare i as binary-long = 1
           perform varying i from 1 by 1 until i > ws-inv-count
               move ws-inv-product-id(i) to inv-product-id
               move ws-inv-quantity(i) to inv-quantity
               write inventory-template
           end-perform
           close inventory
           .

       update-inventory section (t-prod-id as binary-long
                                 t-delta as binary-long).
           perform load-inventory
           move 0 to ws-inv-index

           declare i as binary-long = 1
           perform varying i from 1 by 1 until i > ws-inv-count or
             ws-inv-index > 0
               if ws-inv-product-id(i) = t-prod-id
                   move i to ws-inv-index
               end-if
           end-perform

           if ws-inv-index = 0
               add 1 to ws-inv-count
               move ws-inv-count to ws-inv-index
               move t-prod-id to ws-inv-product-id(ws-inv-index)
               move 0 to ws-inv-quantity(ws-inv-index)
           end-if

           compute ws-inv-quantity(ws-inv-index) =
             ws-inv-quantity(ws-inv-index) + t-delta
           if ws-inv-quantity(ws-inv-index) < 0
               move 0 to ws-inv-quantity(ws-inv-index)
           end-if

           perform save-inventory
           .

       get-product-details section (t-lookup-id as binary-long).
           move "N" to ws-product-found
           move 0 to ws-product-id
           move spaces to ws-product-name ws-product-description
           move 0 to ws-product-cost

           open input products
           declare eof as binary-char = 0
           perform until eof = 1 or product-found
               read products
                   at end
                       move 1 to eof
                   not at end
                       if product-id = t-lookup-id
                           move product-id to ws-product-id
                           move product-name to ws-product-name
                           move product-description to
                             ws-product-description
                           move product-cost to ws-product-cost
                           move "Y" to ws-product-found
                       end-if
               end-read
           end-perform
           close products
           .

       end program BuySellERP.