# 🚀 sql-data-warehouse CRM / ERP Analytics – Pipeline Bronze → Silver → Gold (SQL Server)

Ce dépôt contient un **pipeline SQL Server** pour nettoyer, standardiser et modéliser des données **CRM / ERP** selon l’architecture **Bronze → Silver → Gold**.

---

## 🎯 Objectif

- **Bronze** : données brutes importées telles quelles.
- **Silver** : données nettoyées, cohérentes, prêtes pour l’analytique.
- **Gold** : vues métier (Virtual DataMart) en **star schema** :
  - `gold.dim_customers`
  - `gold.dim_products`
  - `gold.fact_sales`

---

## 🧱 Principales règles de transformation

### Clients (`crm_cust_info`)

- Suppression des doublons par `cst_id` (on garde la ligne **la plus récente**).
- `TRIM()` des noms / prénoms / genre.
- Normalisation :
  - Genre : `M/F` → `Male/Female`, sinon `n/a`.
  - Statut marital : `S/M` → `Single/Married`, sinon `n/a`.

### Produits (`crm_prd_info`)

- Dérivation de `cat_id` à partir de `prd_key`.
- Vérification des catégories dans `erp_px_cat_g1v2`.
- Nettoyage :
  - `TRIM(prd_nm)`, `ISNULL(prd_cost, 0)`.
  - Mapping `prd_line` (`M/R/S/T` → labels lisibles).
- Gestion de l’historique produit (`prd_start_dt` / `prd_end_dt`).

### Ventes (`crm_sales_details`)

- Conversion des dates `yyyymmdd` → `DATE` (avec contrôles de longueur et bornes).
- Règles métier :
  - `sls_sales = sls_quantity * ABS(sls_price)`.
  - Quantités & prix strictement positifs.
- Contrôle des clés de référence :
  - Produit : `sls_prd_key` ↔ `silver.crm_prd_info.prd_key`.
  - Client : `sls_cust_id` ↔ `silver.crm_cust_info.cst_id`.

### ERP (enrichissements)

- `erp_cust_az12` :  
  - Nettoyage de `cid` (suppression éventuelle du préfixe `NAS`).
  - Dates de naissance futures → `NULL`.
  - Normalisation du genre (`Male/Female/n/a`).
- `erp_loc_a101` :  
  - Nettoyage de `cid` (suppression des tirets).
  - Mapping des pays (`DE`, `US/USA`, etc.).

---

## 🌟 Couche Gold (Star Schema)

- **`gold.dim_customers`**  
  Jointure : `crm_cust_info` + `erp_cust_az12` + `erp_loc_a101`  
  → Surrogate key `customer_key`, infos client, genre consolidé, pays, date de création.

- **`gold.dim_products`**  
  `crm_prd_info` (lignes courantes) + `erp_px_cat_g1v2`  
  → `product_key`, infos produit, catégorie / sous-catégorie, coûts, ligne produit.

- **`gold.fact_sales`**  
  `crm_sales_details` + `dim_customers` + `dim_products`  
  → Fait de ventes : montants, quantités, prix, dates (commande / livraison / échéance).

---

## 📁 Organisation (suggestion)

- `01_bronze_to_silver/` : scripts de nettoyage + `INSERT ... SELECT`.
- `02_silver_to_gold/` : création des vues `gold.*`.
- `03_procedures/` : procédure de chargement (TRUNCATE + load Silver).
- `docs/` : data model, data flow, notes métier.

---

## ✅ À retenir

- Même logique partout :  
  **Contrôler → Nettoyer → Standardiser → Charger → Re-contrôler**.
- Architecture prête pour :
  - Power BI / outils BI,
  - analyses de ventes,
  - segmentation clients,
  - analyses produits.

