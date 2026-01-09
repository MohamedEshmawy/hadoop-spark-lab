#!/usr/bin/env python3
"""
Synthetic Data Generator for Hadoop/Spark Teaching Lab

Generates realistic sales transaction data suitable for teaching
distributed data processing concepts. The data is sized to run
on typical lab machines while still demonstrating partitioning
and distributed execution.

Usage:
    python generate_data.py [--size small|medium|large]
    
Output:
    - data/sales/transactions.csv  (main dataset)
    - data/products/catalog.csv    (lookup table)
    - data/products/catalog.json   (same data in JSON)
    - data/customers/customers.csv (customer dimension)
"""

import argparse
import csv
import json
import os
import random
from datetime import datetime, timedelta
from pathlib import Path

# Seed for reproducibility
random.seed(42)

# Configuration
SIZES = {
    'small': {'transactions': 10000, 'products': 100, 'customers': 500},
    'medium': {'transactions': 100000, 'products': 500, 'customers': 2000},
    'large': {'transactions': 1000000, 'products': 1000, 'customers': 10000}
}

# Sample data templates
CATEGORIES = ['Electronics', 'Clothing', 'Home & Garden', 'Books', 'Sports', 
              'Toys', 'Food & Beverage', 'Health & Beauty', 'Automotive', 'Office']

REGIONS = ['North', 'South', 'East', 'West', 'Central']

PAYMENT_METHODS = ['Credit Card', 'Debit Card', 'Cash', 'PayPal', 'Gift Card']

FIRST_NAMES = ['James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 
               'Linda', 'William', 'Elizabeth', 'David', 'Susan', 'Richard', 'Jessica',
               'Joseph', 'Sarah', 'Thomas', 'Karen', 'Charles', 'Nancy']

LAST_NAMES = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
              'Davis', 'Rodriguez', 'Martinez', 'Anderson', 'Taylor', 'Thomas', 'Moore']

def generate_products(num_products):
    """Generate product catalog."""
    products = []
    for i in range(1, num_products + 1):
        category = random.choice(CATEGORIES)
        base_price = random.uniform(5, 500)
        products.append({
            'product_id': f'PROD{i:05d}',
            'product_name': f'{category} Item {i}',
            'category': category,
            'unit_price': round(base_price, 2),
            'cost_price': round(base_price * random.uniform(0.4, 0.7), 2),
            'supplier_id': f'SUP{random.randint(1, 50):03d}',
            'weight_kg': round(random.uniform(0.1, 20), 2),
            'in_stock': random.choice([True, True, True, False])  # 75% in stock
        })
    return products

def generate_customers(num_customers):
    """Generate customer data."""
    customers = []
    for i in range(1, num_customers + 1):
        customers.append({
            'customer_id': f'CUST{i:06d}',
            'first_name': random.choice(FIRST_NAMES),
            'last_name': random.choice(LAST_NAMES),
            'email': f'customer{i}@example.com',
            'region': random.choice(REGIONS),
            'member_since': (datetime(2015, 1, 1) + 
                           timedelta(days=random.randint(0, 3000))).strftime('%Y-%m-%d'),
            'loyalty_tier': random.choice(['Bronze', 'Silver', 'Gold', 'Platinum'])
        })
    return customers

def generate_transactions(num_transactions, products, customers):
    """Generate sales transactions."""
    transactions = []
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2024, 12, 31)
    date_range = (end_date - start_date).days
    
    for i in range(1, num_transactions + 1):
        product = random.choice(products)
        customer = random.choice(customers)
        quantity = random.randint(1, 10)
        unit_price = product['unit_price']
        
        # Add some price variation (sales, promotions)
        if random.random() < 0.2:  # 20% chance of discount
            unit_price *= random.uniform(0.7, 0.95)
        
        transactions.append({
            'transaction_id': f'TXN{i:08d}',
            'transaction_date': (start_date + 
                               timedelta(days=random.randint(0, date_range))).strftime('%Y-%m-%d'),
            'transaction_time': f'{random.randint(8,21):02d}:{random.randint(0,59):02d}:{random.randint(0,59):02d}',
            'customer_id': customer['customer_id'],
            'product_id': product['product_id'],
            'quantity': quantity,
            'unit_price': round(unit_price, 2),
            'total_amount': round(unit_price * quantity, 2),
            'payment_method': random.choice(PAYMENT_METHODS),
            'store_region': customer['region'],
            'is_online': random.choice([True, False])
        })
    
    return transactions

def save_csv(data, filepath):
    """Save data to CSV file."""
    if not data:
        return
    filepath.parent.mkdir(parents=True, exist_ok=True)
    with open(filepath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)
    print(f"  Created: {filepath} ({len(data):,} rows)")

def save_json(data, filepath):
    """Save data to JSON file (one object per line for Spark)."""
    filepath.parent.mkdir(parents=True, exist_ok=True)
    with open(filepath, 'w', encoding='utf-8') as f:
        for item in data:
            f.write(json.dumps(item) + '\n')
    print(f"  Created: {filepath} ({len(data):,} rows)")

def main():
    parser = argparse.ArgumentParser(description='Generate sample data for Hadoop/Spark lab')
    parser.add_argument('--size', choices=['small', 'medium', 'large'], default='medium',
                       help='Dataset size (default: medium)')
    args = parser.parse_args()
    
    config = SIZES[args.size]
    base_path = Path(__file__).parent
    
    print(f"\nGenerating {args.size} dataset...")
    print(f"  Transactions: {config['transactions']:,}")
    print(f"  Products: {config['products']:,}")
    print(f"  Customers: {config['customers']:,}")
    print()
    
    # Generate data
    products = generate_products(config['products'])
    customers = generate_customers(config['customers'])
    transactions = generate_transactions(config['transactions'], products, customers)
    
    # Save files
    save_csv(products, base_path / 'products' / 'catalog.csv')
    save_json(products, base_path / 'products' / 'catalog.json')
    save_csv(customers, base_path / 'customers' / 'customers.csv')
    save_csv(transactions, base_path / 'sales' / 'transactions.csv')
    
    print(f"\nData generation complete!")
    print(f"Total disk size: ~{os.path.getsize(base_path / 'sales' / 'transactions.csv') / 1024 / 1024:.1f} MB")

if __name__ == '__main__':
    main()

