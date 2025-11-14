# 🌱 Sustainable Textile Tracking

A blockchain-based smart contract for tracking sustainable textile materials from source to finished product, ensuring transparency and authenticity in the supply chain.

## 📋 Overview

This Clarity smart contract enables end-to-end tracking of sustainable textile materials like organic cotton and recycled polyester. It provides on-chain proof of material origin, certification, and movement through the supply chain.

## ✨ Features

- 🏭 **Source Registration** - Register farms, recycling facilities, and other material sources
- 🌾 **Material Tracking** - Track raw materials with origin proof and certifications
- 📦 **Batch Management** - Create and manage material batches through the supply chain
- 🚚 **Transfer History** - Complete audit trail of material movement and ownership
- 👕 **Product Creation** - Create finished products with material provenance
- ✅ **Verification System** - Contract owner can verify sources, materials, and products

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of Clarity and Stacks blockchain

### Installation

```bash
git clone <repository-url>
cd Sustainable-Textile-Tracking
clarinet check
```

## 📖 Usage

### Register a Source

Register a material source (farm, recycling facility, etc.):

```clarity
(contract-call? .Sustainable-Textile-Tracking register-source 
  "Green Cotton Farm" 
  "California, USA" 
  "Organic Cotton Farm")
```

### Certify a Source (Contract Owner Only)

```clarity
(contract-call? .Sustainable-Textile-Tracking certify-source u1)
```

### Register Material

Register raw material from your source:

```clarity
(contract-call? .Sustainable-Textile-Tracking register-material 
  u1 
  "Organic Cotton" 
  u1000 
  "kg" 
  u1698000000 
  "GOTS Certified, Fair Trade")
```

### Create a Batch

Create a batch from registered material:

```clarity
(contract-call? .Sustainable-Textile-Tracking create-batch 
  u1 
  u500 
  "Processing Facility, India")
```

### Transfer Batch

Transfer batch to another party:

```clarity
(contract-call? .Sustainable-Textile-Tracking transfer-batch 
  u1 
  'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC 
  "Textile Mill, Bangladesh")
```

### Update Batch Status

```clarity
(contract-call? .Sustainable-Textile-Tracking update-batch-status 
  u1 
  "processing")
```

### Create Product

Create a finished product from batches:

```clarity
(contract-call? .Sustainable-Textile-Tracking create-product 
  "Eco T-Shirt" 
  "Apparel" 
  (list u1 u2))
```

### Verify Product (Contract Owner Only)

```clarity
(contract-call? .Sustainable-Textile-Tracking verify-product u1)
```

## 🔍 Read-Only Functions

### Get Source Information

```clarity
(contract-call? .Sustainable-Textile-Tracking get-source u1)
```

### Get Material Information

```clarity
(contract-call? .Sustainable-Textile-Tracking get-material u1)
```

### Get Batch Information

```clarity
(contract-call? .Sustainable-Textile-Tracking get-batch u1)
```

### Get Product Information

```clarity
(contract-call? .Sustainable-Textile-Tracking get-product u1)
```

### Get Batch History

```clarity
(contract-call? .Sustainable-Textile-Tracking get-batch-history-entry u1 u0)
(contract-call? .Sustainable-Textile-Tracking get-batch-history-length u1)
```

### Get Source Materials

```clarity
(contract-call? .Sustainable-Textile-Tracking get-source-material u1 u0)
(contract-call? .Sustainable-Textile-Tracking get-source-material-count u1)
```

## 🔐 Error Codes

- `u100` - Owner only operation
- `u101` - Resource not found
- `u102` - Resource already exists
- `u103` - Invalid source
- `u104` - Invalid material
- `u105` - Unauthorized operation
- `u106` - Insufficient quantity
- `u107` - Invalid product
- `u108` - Already verified

## 🏗️ Contract Architecture

### Data Maps

- **sources** - Registered material sources
- **materials** - Registered raw materials
- **batches** - Material batches in transit
- **products** - Finished products
- **batch-history** - Complete transfer history
- **source-materials** - Materials linked to sources

## 🌟 Use Cases

1. **Fashion Brands** - Verify sustainable material claims
2. **Consumers** - Check product authenticity and origin
3. **Regulators** - Audit supply chain compliance
4. **Suppliers** - Prove material certifications

## 🧪 Testing

Run the test suite:

```bash
clarinet test
```

Check contract syntax:

```bash
clarinet check
```

## 📝 License

MIT License - See LICENSE file for details

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For questions or issues, please open an issue on GitHub.

---

Made with 💚 for a more sustainable textile industry
