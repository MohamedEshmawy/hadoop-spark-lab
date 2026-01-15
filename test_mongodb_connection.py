#!/usr/bin/env python3
"""
Test MongoDB connection and sample data
"""
import sys
import json
from datetime import datetime

print("=" * 80)
print("TESTING MONGODB CONNECTION")
print("=" * 80)

try:
    from pymongo import MongoClient
    
    uri = "mongodb+srv://inst:123@cluster0.noagfhj.mongodb.net/"
    print(f"\nConnecting to MongoDB Atlas...")
    print(f"URI: {uri}")
    
    client = MongoClient(uri, serverSelectionTimeoutMS=10000)
    
    # Test connection
    client.admin.command('ping')
    print("✓ MongoDB connection successful!")
    
    # Get database and collection
    db = client['sample_airbnb']
    collection = db['listingsAndReviews']
    
    # Count documents
    count = collection.count_documents({})
    print(f"\n✓ Found {count:,} documents in sample_airbnb.listingsAndReviews")
    
    # Get sample document
    print("\n" + "=" * 80)
    print("SAMPLE DOCUMENT")
    print("=" * 80)
    sample = collection.find_one()
    if sample:
        print(f"_id: {sample.get('_id')}")
        print(f"Name: {sample.get('name', 'N/A')}")
        print(f"Property type: {sample.get('property_type', 'N/A')}")
        print(f"Room type: {sample.get('room_type', 'N/A')}")
        print(f"Price: {sample.get('price', 'N/A')}")
        print(f"Accommodates: {sample.get('accommodates', 'N/A')}")
        print(f"Last scraped: {sample.get('last_scraped', 'N/A')}")
        print(f"Number of reviews: {sample.get('number_of_reviews', 'N/A')}")
        
        # Check nested structures
        if 'host' in sample:
            print(f"\nHost info:")
            print(f"  - host_id: {sample['host'].get('host_id', 'N/A')}")
            print(f"  - host_name: {sample['host'].get('host_name', 'N/A')}")
            print(f"  - host_is_superhost: {sample['host'].get('host_is_superhost', 'N/A')}")
        
        if 'address' in sample:
            print(f"\nAddress info:")
            print(f"  - street: {sample['address'].get('street', 'N/A')}")
            print(f"  - market: {sample['address'].get('market', 'N/A')}")
            print(f"  - country: {sample['address'].get('country', 'N/A')}")
        
        if 'reviews' in sample:
            print(f"\nReviews: {len(sample['reviews'])} embedded reviews")
            if sample['reviews']:
                first_review = sample['reviews'][0]
                print(f"  First review: {first_review.get('comments', 'N/A')[:100]}...")
    
    client.close()
    print("\n" + "=" * 80)
    print("✓ MONGODB CONNECTION TEST PASSED")
    print("=" * 80)
    sys.exit(0)
    
except Exception as e:
    print(f"\n✗ MONGODB CONNECTION TEST FAILED")
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

