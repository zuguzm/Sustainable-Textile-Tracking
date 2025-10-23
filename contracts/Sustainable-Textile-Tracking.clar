;; title: Sustainable-Textile-Tracking

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-source (err u103))
(define-constant err-invalid-material (err u104))
(define-constant err-unauthorized (err u105))
(define-constant err-insufficient-quantity (err u106))
(define-constant err-invalid-product (err u107))
(define-constant err-already-verified (err u108))

(define-data-var source-nonce uint u0)
(define-data-var material-nonce uint u0)
(define-data-var batch-nonce uint u0)
(define-data-var product-nonce uint u0)

(define-map sources
  uint
  {
    owner: principal,
    name: (string-ascii 50),
    location: (string-ascii 100),
    source-type: (string-ascii 30),
    certified: bool,
    registration-height: uint,
    active: bool
  }
)

(define-map materials
  uint
  {
    source-id: uint,
    material-type: (string-ascii 30),
    quantity: uint,
    unit: (string-ascii 10),
    harvest-date: uint,
    certifications: (string-ascii 200),
    verified: bool,
    created-height: uint
  }
)

(define-map batches
  uint
  {
    material-id: uint,
    current-owner: principal,
    quantity: uint,
    location: (string-ascii 100),
    status: (string-ascii 20),
    created-height: uint,
    last-updated: uint
  }
)

(define-map products
  uint
  {
    creator: principal,
    product-name: (string-ascii 50),
    product-type: (string-ascii 30),
    batch-ids: (list 10 uint),
    created-height: uint,
    verified: bool
  }
)

(define-map batch-history
  { batch-id: uint, entry-id: uint }
  {
    from-owner: principal,
    to-owner: principal,
    location: (string-ascii 100),
    timestamp: uint
  }
)

(define-map batch-history-count
  uint
  uint
)

(define-map source-materials
  { source-id: uint, material-index: uint }
  uint
)

(define-map source-material-count
  uint
  uint
)

(define-public (register-source (name (string-ascii 50)) (location (string-ascii 100)) (source-type (string-ascii 30)))
  (let
    (
      (new-source-id (+ (var-get source-nonce) u1))
    )
    (map-set sources new-source-id {
      owner: tx-sender,
      name: name,
      location: location,
      source-type: source-type,
      certified: false,
      registration-height: stacks-block-height,
      active: true
    })
    (var-set source-nonce new-source-id)
    (ok new-source-id)
  )
)

(define-public (certify-source (source-id uint))
  (let
    (
      (source (unwrap! (map-get? sources source-id) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (get active source) err-not-found)
    (map-set sources source-id (merge source { certified: true }))
    (ok true)
  )
)

(define-public (deactivate-source (source-id uint))
  (let
    (
      (source (unwrap! (map-get? sources source-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get owner source)) err-unauthorized)
    (map-set sources source-id (merge source { active: false }))
    (ok true)
  )
)

(define-public (register-material (source-id uint) (material-type (string-ascii 30)) (quantity uint) (unit (string-ascii 10)) (harvest-date uint) (certifications (string-ascii 200)))
  (let
    (
      (source (unwrap! (map-get? sources source-id) err-invalid-source))
      (new-material-id (+ (var-get material-nonce) u1))
      (material-count (default-to u0 (map-get? source-material-count source-id)))
    )
    (asserts! (is-eq tx-sender (get owner source)) err-unauthorized)
    (asserts! (get active source) err-invalid-source)
    (map-set materials new-material-id {
      source-id: source-id,
      material-type: material-type,
      quantity: quantity,
      unit: unit,
      harvest-date: harvest-date,
      certifications: certifications,
      verified: false,
      created-height: stacks-block-height
    })
    (map-set source-materials { source-id: source-id, material-index: material-count } new-material-id)
    (map-set source-material-count source-id (+ material-count u1))
    (var-set material-nonce new-material-id)
    (ok new-material-id)
  )
)

(define-public (verify-material (material-id uint))
  (let
    (
      (material (unwrap! (map-get? materials material-id) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (get verified material)) err-already-verified)
    (map-set materials material-id (merge material { verified: true }))
    (ok true)
  )
)

(define-public (create-batch (material-id uint) (quantity uint) (location (string-ascii 100)))
  (let
    (
      (material (unwrap! (map-get? materials material-id) err-invalid-material))
      (source (unwrap! (map-get? sources (get source-id material)) err-invalid-source))
      (new-batch-id (+ (var-get batch-nonce) u1))
    )
    (asserts! (is-eq tx-sender (get owner source)) err-unauthorized)
    (asserts! (<= quantity (get quantity material)) err-insufficient-quantity)
    (map-set batches new-batch-id {
      material-id: material-id,
      current-owner: tx-sender,
      quantity: quantity,
      location: location,
      status: "created",
      created-height: stacks-block-height,
      last-updated: stacks-block-height
    })
    (map-set batch-history { batch-id: new-batch-id, entry-id: u0 } {
      from-owner: tx-sender,
      to-owner: tx-sender,
      location: location,
      timestamp: stacks-block-height
    })
    (map-set batch-history-count new-batch-id u1)
    (var-set batch-nonce new-batch-id)
    (ok new-batch-id)
  )
)

(define-public (transfer-batch (batch-id uint) (new-owner principal) (new-location (string-ascii 100)))
  (let
    (
      (batch (unwrap! (map-get? batches batch-id) err-not-found))
      (history-count (default-to u0 (map-get? batch-history-count batch-id)))
    )
    (asserts! (is-eq tx-sender (get current-owner batch)) err-unauthorized)
    (map-set batches batch-id (merge batch {
      current-owner: new-owner,
      location: new-location,
      status: "transferred",
      last-updated: stacks-block-height
    }))
    (map-set batch-history { batch-id: batch-id, entry-id: history-count } {
      from-owner: tx-sender,
      to-owner: new-owner,
      location: new-location,
      timestamp: stacks-block-height
    })
    (map-set batch-history-count batch-id (+ history-count u1))
    (ok true)
  )
)

(define-public (update-batch-status (batch-id uint) (new-status (string-ascii 20)))
  (let
    (
      (batch (unwrap! (map-get? batches batch-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get current-owner batch)) err-unauthorized)
    (map-set batches batch-id (merge batch {
      status: new-status,
      last-updated: stacks-block-height
    }))
    (ok true)
  )
)

(define-public (create-product (product-name (string-ascii 50)) (product-type (string-ascii 30)) (batch-ids (list 10 uint)))
  (let
    (
      (new-product-id (+ (var-get product-nonce) u1))
    )
    (asserts! (> (len batch-ids) u0) err-invalid-product)
    (asserts! (is-valid-batch-list batch-ids tx-sender) err-unauthorized)
    (map-set products new-product-id {
      creator: tx-sender,
      product-name: product-name,
      product-type: product-type,
      batch-ids: batch-ids,
      created-height: stacks-block-height,
      verified: false
    })
    (var-set product-nonce new-product-id)
    (ok new-product-id)
  )
)

(define-public (verify-product (product-id uint))
  (let
    (
      (product (unwrap! (map-get? products product-id) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (get verified product)) err-already-verified)
    (map-set products product-id (merge product { verified: true }))
    (ok true)
  )
)

(define-read-only (get-source (source-id uint))
  (ok (map-get? sources source-id))
)

(define-read-only (get-material (material-id uint))
  (ok (map-get? materials material-id))
)

(define-read-only (get-batch (batch-id uint))
  (ok (map-get? batches batch-id))
)

(define-read-only (get-product (product-id uint))
  (ok (map-get? products product-id))
)

(define-read-only (get-batch-history-entry (batch-id uint) (entry-id uint))
  (ok (map-get? batch-history { batch-id: batch-id, entry-id: entry-id }))
)

(define-read-only (get-batch-history-length (batch-id uint))
  (ok (default-to u0 (map-get? batch-history-count batch-id)))
)

(define-read-only (get-source-material (source-id uint) (material-index uint))
  (ok (map-get? source-materials { source-id: source-id, material-index: material-index }))
)

(define-read-only (get-source-material-count (source-id uint))
  (ok (default-to u0 (map-get? source-material-count source-id)))
)

(define-read-only (get-source-nonce)
  (ok (var-get source-nonce))
)

(define-read-only (get-material-nonce)
  (ok (var-get material-nonce))
)

(define-read-only (get-batch-nonce)
  (ok (var-get batch-nonce))
)

(define-read-only (get-product-nonce)
  (ok (var-get product-nonce))
)

(define-private (is-valid-batch-list (batch-ids (list 10 uint)) (owner principal))
  (fold check-batch-owner batch-ids true)
)

(define-private (check-batch-owner (batch-id uint) (previous-result bool))
  (if previous-result
    (match (map-get? batches batch-id)
      batch (is-eq (get current-owner batch) tx-sender)
      false
    )
    false
  )
)
