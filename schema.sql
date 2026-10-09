-- ==============================================================
-- GRAN & TECH E-COMMERCE PLATFORM (Jakarta EE / MySQL)
-- Database Architecture: grantech_db
-- Author: Kusal Nirmala (Batch: CO/SE/Intake5)
-- ==============================================================

DROP DATABASE IF EXISTS grantech_db;
CREATE DATABASE grantech_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE grantech_db;

-- 1. USERS TABLE
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    address VARCHAR(255),
    city VARCHAR(50) DEFAULT 'Colombo',
    postal_code VARCHAR(20) DEFAULT '00300',
    role ENUM('CUSTOMER', 'ADMIN') DEFAULT 'CUSTOMER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. CATEGORIES TABLE
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(50) NOT NULL UNIQUE,
    icon_class VARCHAR(50) NOT NULL,
    display_order INT DEFAULT 0
);

-- 3. PRODUCTS TABLE
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(150) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    sku VARCHAR(50) NOT NULL UNIQUE,
    stock_quantity INT NOT NULL DEFAULT 50,
    rating DECIMAL(2,1) DEFAULT 4.8,
    reviews_count INT DEFAULT 120,
    main_image VARCHAR(500) NOT NULL,
    badge VARCHAR(50),
    tech_specs TEXT,
    shipping_info TEXT,
    warranty_info TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON UPDATE CASCADE
);

-- 4. PRODUCT IMAGES (GALLERY)
CREATE TABLE product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    display_order INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 5. PRODUCT VARIANTS (RAM, SSD, COLOR)
CREATE TABLE product_variants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    variant_type VARCHAR(50) NOT NULL, -- 'RAM', 'STORAGE'
    variant_value VARCHAR(100) NOT NULL,
    price_delta DECIMAL(10,2) DEFAULT 0.00,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 6. ORDERS TABLE
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_no VARCHAR(50) NOT NULL UNIQUE,
    user_id INT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    shipping_address VARCHAR(255) NOT NULL,
    shipping_city VARCHAR(50) NOT NULL,
    shipping_postal_code VARCHAR(20),
    subtotal DECIMAL(10,2) NOT NULL,
    shipping_fee DECIMAL(10,2) DEFAULT 0.00,
    tax DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'CREDIT_CARD',
    payment_status VARCHAR(50) DEFAULT 'PAID',
    order_status ENUM('PROCESSING', 'SHIPPED', 'DELIVERED', 'FULFILLED', 'CANCELLED') DEFAULT 'PROCESSING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 7. ORDER ITEMS TABLE
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    product_image VARCHAR(500),
    variant_summary VARCHAR(100),
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE
);

-- 8. SUPPORT TICKETS TABLE
CREATE TABLE support_tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_no VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    status ENUM('OPEN', 'RESOLVED', 'CLOSED') DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================
-- INITIAL SEED DATA
-- ==============================================================

-- 1. Users (Admin + Demo Customer)
-- SHA-256 for 'admin123' -> 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
-- SHA-256 for 'password123' -> ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f
INSERT INTO users (full_name, email, password_hash, phone, address, city, postal_code, role) VALUES
('System Administrator', 'admin@grantech.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 123 4567', '45 Galle Face Terrace', 'Colombo', '00300', 'ADMIN'),
('Kusal Nirmala', 'kusal@grantech.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '+94 71 987 6543', '12 Innovation Way', 'Colombo', '00700', 'CUSTOMER'),
('Saha Madushanka', 'saha@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '+94 76 555 1234', '78 Kandy Road', 'Kiribathgoda', '11600', 'CUSTOMER');

-- 2. Categories
INSERT INTO categories (id, name, slug, icon_class, display_order) VALUES
(1, 'Computers', 'computers', 'fal fa-laptop', 1),
(2, 'Phones', 'phones', 'fal fa-mobile-android', 2),
(3, 'Wearables', 'wearables', 'fal fa-watch', 3),
(4, 'Audio', 'audio', 'fal fa-headphones-alt', 4),
(5, 'Drones', 'drones', 'fal fa-drone', 5),
(6, 'Smart Home', 'smart-home', 'fal fa-home-lg-alt', 6);

-- 3. Products
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) VALUES
(1, 1, 'Aether Pro Laptop', 'aether-pro-laptop', 
 'Engineered for the elite. The Aether Pro delivers desktop-level performance in an impossibly thin aerospace-grade aluminum chassis. Featuring the new M-Series architecture, advanced thermal management, and a stunning 16-inch Retina Liquid display.',
 1999.00, 2299.00, 'GT-LP-01', 24, 4.9, 142, 
 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800&auto=format&fit=crop&q=80', 
 'NEW RELEASE', 
 'Processor: 12-Core CPU, 19-Core GPU | Display: 16.2-inch Liquid Retina XDR display (3456x2234) | Battery: Up to 22 hours | Ports: 3x Thunderbolt 4, HDMI, SDXC, MagSafe 3', 
 'Free worldwide priority courier (2-4 business days). Signature required on delivery.', 
 '2-Year Official GRAN & TECH Manufacturer Warranty with accidental damage protection option.'),

(2, 2, 'Pro 15 Mobile', 'pro-15-mobile', 
 'Sculpted in aerospace titanium with textured matte glass. Features the A17 Pro photonic neural chip, next-gen 48MP periscope telephoto sensor, and customizable action haptics.',
 999.00, 1199.00, 'GT-PH-01', 45, 4.8, 98, 
 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800&auto=format&fit=crop&q=80', 
 'HOT', 
 'Display: 6.7-inch Super Retina XDR with ProMotion 120Hz | Camera: 48MP Main, 12MP Ultra-wide, 12MP 5x Telephoto | Storage: 256GB NVMe | Battery: 4422 mAh Fast-charging', 
 'Next-day domestic dispatch. Sealed packaging with tamper-proof anti-theft holograms.', 
 '1-Year Global Apple-standard hardware warranty with 24/7 technical hotline access.'),

(3, 3, 'ARE2 Smart Watch', 'are2-smart-watch', 
 'High-precision titanium housing with sapphire crystal lens. Continuous ECG, blood oxygen metrics, dual-frequency GPS navigation, and 72-hour extended expedition battery.',
 499.00, 599.00, 'GT-WB-01', 38, 4.7, 76, 
 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&auto=format&fit=crop&q=80', 
 'NEW', 
 'Case: 49mm Aerospace Titanium | Water Resistance: 100m ISO standard with depth gauge | Sensors: ECG, SpO2, Skin Temp, Dual GPS | Battery: Up to 72h Low Power Mode', 
 'Dispatched via insured express parcel. Includes magnetic fast-charger braided cable.', 
 '2-Year Limited International Warranty against mechanical and water-ingress faults.'),

(4, 4, 'Sonic Headphones', 'sonic-headphones', 
 'Acoustic perfection crafted with custom 40mm beryllium drivers. Active noise cancellation with dynamic transparency algorithms and ultra-plush memory foam ear cushions.',
 349.00, 399.00, 'GT-AU-01', 52, 4.9, 115, 
 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format&fit=crop&q=80', 
 'HOT', 
 'Drivers: 40mm Custom Neodymium Beryllium | Frequency: 10Hz - 40,000Hz Hi-Res Audio | Codecs: LDAC, aptX Adaptive, AAC | Battery: 40 Hours playback with ANC enabled', 
 'Ships in hard-shell protective travel case with 3.5mm gold-plated audio cable.', 
 '1-Year Replacement Warranty for any driver imbalance or electrical failure.'),

(5, 1, 'Horizon 32\" 4K Monitor', 'horizon-32-4k-monitor', 
 'Cinema-grade 32-inch 4K UHD Quantum Mini-LED display with 144Hz refresh rate, 99% DCI-P3 color accuracy, and built-in 96W USB-C single-cable power delivery hub.',
 899.00, 1049.00, 'GT-LP-02', 18, 4.8, 64, 
 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&auto=format&fit=crop&q=80', 
 'POPULAR', 
 'Panel: 32-inch IPS Mini-LED 4K (3840x2160) | Refresh: 144Hz AMD FreeSync Premium Pro | Brightness: 1000 nits Peak HDR1000 | Connectivity: Thunderbolt 4 96W PD, 2x HDMI 2.1, DP 1.4', 
 'Heavy-duty freight shipping with shock-absorbent custom foam casing.', 
 '3-Year Zero-Dead-Pixel guarantee and full panel exchange warranty.'),

(6, 6, 'Echo Smart Speaker Hub', 'echo-smart-speaker-hub', 
 'Omnidirectional room-filling acoustics with computational audio tuning. Acts as an ultra-fast Zigbee and Matter smart-home gateway with integrated encrypted voice AI.',
 149.00, 199.00, 'GT-SH-01', 60, 4.6, 88, 
 'https://images.unsplash.com/photo-1543512214-318c7553f230?w=800&auto=format&fit=crop&q=80', 
 'BESTSELLER', 
 'Acoustics: 3.0-inch Neodymium Woofer + Dual 0.8-inch Silk Dome Tweeters | Protocols: Matter, Thread, Zigbee 3.0, Wi-Fi 6 | Microphones: 6-mic Far-field array with privacy toggle', 
 'Standard 2-3 business day courier delivery.', 
 '1-Year Full replacement warranty covering hardware and smart home controller connectivity.'),

(7, 5, 'AeroX 4K Camera Drone', 'aerox-4k-drone', 
 'Ultra-lightweight foldable carbon composite drone with 3-axis mechanical gimbal, 4K/60fps HDR video capture, and 360-degree omnidirectional APAS obstacle avoidance sensors.',
 1199.00, 1399.00, 'GT-DR-01', 15, 4.9, 53, 
 'https://images.unsplash.com/photo-1507582020432-2a3bc418123f?w=800&auto=format&fit=crop&q=80', 
 'NEW', 
 'Camera: 1-inch CMOS 20MP Sensor, 4K/60fps 10-bit D-Log M | Flight Time: 45 Minutes max per intelligent battery | Range: 15km O4 Video Transmission | Max Speed: 68 km/h in Sport Mode', 
 'Ships in weatherproof carrying case with 3x intelligent flight batteries and multi-charger.', 
 '1-Year FlyAway Protection and crash damage repair support included.'),

(8, 1, 'CyberPro Mechanical Keyboard', 'cyberpro-mechanical-keyboard', 
 'CNC-machined solid aluminum chassis with hot-swappable gasket-mounted mechanical switches, south-facing per-key RGB, and tri-mode wireless connectivity.',
 179.00, 219.00, 'GT-LP-03', 70, 4.8, 92, 
 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=800&auto=format&fit=crop&q=80', 
 'HOT', 
 'Layout: 75% Compact 82-Key | Switches: Pre-lubed Gateron Oil King Linear | Connectivity: 2.4GHz Wireless, Bluetooth 5.2, USB-C Braided | Battery: 4000mAh up to 200h without RGB', 
 'Dispatched with custom keycap puller, switch extractor, and braided coiled cable.', 
 '2-Year Switch and PCB electronic warranty.');

-- 4. Product Gallery Images
INSERT INTO product_images (product_id, image_url, display_order) VALUES
(1, 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800&auto=format&fit=crop&q=80', 1),
(1, 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=800&auto=format&fit=crop&q=80', 2),
(1, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop&q=80', 3),
(2, 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800&auto=format&fit=crop&q=80', 1),
(2, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&auto=format&fit=crop&q=80', 2),
(3, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&auto=format&fit=crop&q=80', 1),
(4, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format&fit=crop&q=80', 1);

-- 5. Product Variants (RAM & SSD Configurator for Aether Pro)
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default) VALUES
(1, 'RAM', '16GB RAM', 0.00, TRUE),
(1, 'RAM', '32GB RAM', 400.00, FALSE),
(1, 'STORAGE', '512GB SSD', 0.00, FALSE),
(1, 'STORAGE', '1TB SSD', 200.00, TRUE);

-- 6. Historical Orders (Matching Admin Dashboard Screenshot in SRS)
INSERT INTO orders (id, order_no, user_id, customer_name, customer_email, shipping_address, shipping_city, shipping_postal_code, subtotal, shipping_fee, tax, total_amount, payment_method, payment_status, order_status, created_at) VALUES
(1, 'GT-8492', 3, 'Saha Madushanka', 'saha@example.com', '78 Kandy Road', 'Kiribathgoda', '11600', 2348.00, 0.00, 0.00, 2348.00, 'CREDIT_CARD', 'PAID', 'PROCESSING', DATE_SUB(NOW(), INTERVAL 5 MINUTE)),
(2, 'GT-8491', 2, 'Jane Doe', 'jane@example.com', '14 Ocean Crest Ave', 'Colombo', '00300', 999.00, 0.00, 0.00, 999.00, 'CREDIT_CARD', 'PAID', 'FULFILLED', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(3, 'GT-8490', 2, 'John Smith', 'john@example.com', '89 Park Lane', 'Nugegoda', '10250', 349.00, 0.00, 0.00, 349.00, 'CREDIT_CARD', 'PAID', 'FULFILLED', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(4, 'GT-8489', 2, 'Alex Turner', 'alex@example.com', '23 Victoria Way', 'Colombo', '00700', 1199.00, 0.00, 0.00, 1199.00, 'CREDIT_CARD', 'PAID', 'FULFILLED', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 7. Order Items
INSERT INTO order_items (order_id, product_id, product_name, product_image, variant_summary, unit_price, quantity, subtotal) VALUES
(1, 1, 'Aether Pro Laptop', 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800', '16GB RAM | 1TB SSD', 1999.00, 1, 1999.00),
(1, 4, 'Sonic Headphones', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800', 'Noise Cancelling Studio', 349.00, 1, 349.00),
(2, 2, 'Pro 15 Mobile', 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800', 'Titanium Black', 999.00, 1, 999.00),
(3, 4, 'Sonic Headphones', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800', 'Noise Cancelling Studio', 349.00, 1, 349.00),
(4, 7, 'AeroX 4K Camera Drone', 'https://images.unsplash.com/photo-1507582020432-2a3bc418123f?w=800', 'Obstacle Sensing', 1199.00, 1, 1199.00);

-- 8. Support Tickets
INSERT INTO support_tickets (ticket_no, name, email, subject, message, status) VALUES
('TCK-1042', 'Kasun Perera', 'kasun@gmail.com', 'Inquiry on Aether Pro Warranty Extension', 'Hi, I would like to purchase the 3-year extended warranty for my Aether Pro Laptop. How do I proceed with payment?', 'OPEN'),
('TCK-1041', 'Dilini Silva', 'dilini@yahoo.com', 'Courier Tracking Details for Order #GT-8491', 'Could you please provide the tracking code for the Pro 15 Mobile dispatched yesterday?', 'RESOLVED');
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (9, 1, 'Aether Air 13" Ultrabook', 'aether-air-13-ultrabook', 'Impossibly thin and remarkably fast. The Aether Air pairs a fanless silent thermal architecture with all-day 18-hour battery endurance. Featuring a vibrant 13.6-inch Liquid Retina display and quad-speaker spatial audio.', 1299.0, 1499.0, 'GT-LP-04', 35, 4.8, 120, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Processor: 8-Core CPU, 10-Core GPU | Display: 13.6-inch Liquid Retina (2560x1664) | Battery: Up to 18 Hours | Ports: 2x Thunderbolt 4, MagSafe 3, 3.5mm Jack', 'Free express delivery. Dispatched in tamper-evident sealed packaging.', '2-Year GRAN & TECH Worldwide Hardware Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (10, 1, 'Aether Studio 14" Workstation', 'aether-studio-14-workstation', 'Built for extreme engineering, 3D rendering, and neural model workflows. Powered by a 14-core high-performance CPU with 30-core graphics, liquid cooling chamber, and 120Hz ProMotion XDR display.', 2399.0, 2699.0, 'GT-LP-05', 18, 4.9, 88, 'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=800&auto=format&fit=crop&q=80', 'FLAGSHIP', 'Processor: 14-Core CPU, 30-Core GPU | Display: 14.2-inch Liquid Retina XDR (3024x1964) 120Hz | RAM: 36GB Unified Memory | Storage: 1TB NVMe Gen4', 'Complimentary white-glove courier dispatch with real-time GPS tracking.', '3-Year Enterprise Care with 24/7 priority technician support.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (11, 1, 'Titan Stealth 16" Gaming Rig', 'titan-stealth-16-gaming', 'Uncompromised desktop GPU power packed into a stealth matte-black magnesium alloy body. Features an NVIDIA GeForce RTX 4090 Mobile, 240Hz OLED gaming display, and custom per-key mechanical actuation.', 2499.0, 2799.0, 'GT-LP-06', 14, 4.9, 95, 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800&auto=format&fit=crop&q=80', 'HOT', 'GPU: NVIDIA GeForce RTX 4090 16GB VRAM | CPU: Intel Core i9-14900HX 24-Core | Display: 16-inch 240Hz QHD+ OLED (2560x1600) | Thermals: Dual Liquid Metal Vapor Chamber', 'Insured priority freight delivery with signature requirement.', '2-Year Performance Hardware Warranty covering thermal and GPU components.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (12, 1, 'Carbon Blade 15" Slim Laptop', 'carbon-blade-15-slim', 'Sculpted from woven carbon fiber and aerospace aluminum. Featherweight 1.1kg design equipped with next-gen 45 TOPS neural processing engine for on-device AI synthesis.', 1749.0, 1999.0, 'GT-LP-07', 28, 4.7, 64, 'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=800&auto=format&fit=crop&q=80', 'NEW', 'Processor: Snapdragon X Elite 12-Core 3.8GHz | NPU: 45 TOPS Hexagon Engine | Display: 15.0-inch 2.8K OLED Touch (2880x1800) | Weight: 1.14 kg', 'Next-day priority delivery in shock-resistant packaging.', '2-Year Official Manufacturer Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (13, 1, 'Aether Studio Tower', 'aether-studio-tower', 'A modular architectural centerpiece designed for Hollywood colorists, scientific simulations, and high-throughput compilation. Features tool-less aluminum side access and dual GPU expansion.', 2999.0, 3499.0, 'GT-DT-01', 12, 5.0, 42, 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800&auto=format&fit=crop&q=80', 'STUDIO', 'Processor: AMD Threadripper 7960X 24-Core | Memory: 64GB DDR5 ECC Quad-Channel | Storage: 2TB PCIe 5.0 SSD | Power: 1200W Titanium 80+ Modular', 'Heavy freight palletized courier dispatch with customized wooden crate.', '3-Year Comprehensive On-Site Enterprise Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (14, 1, 'Core Pro Mini Workstation', 'core-pro-mini-workstation', 'Impossibly small, phenomenally capable. A 0.8-liter precision CNC block delivering workstation-grade CPU power, triple 4K display outputs, and dual 2.5GbE network links.', 1099.0, 1299.0, 'GT-DT-02', 32, 4.8, 79, 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'CPU: AMD Ryzen 9 7940HS 8-Core / 16-Thread | Graphics: Radeon 780M | RAM: 32GB DDR5 5600MHz | Networking: Dual 2.5GbE RJ-45, Wi-Fi 6E', 'Standard international priority airmail (2-3 business days).', '2-Year Replacement Warranty on all core logic components.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (15, 1, 'UltraVision 49" Curved SuperWide', 'ultravision-49-curved-superwide', 'Eliminate multi-monitor bezels forever. A panoramic 32:9 Quantum Dot OLED panel with an immersive 1800R curvature, blazing 240Hz refresh rate, and built-in KVM hardware switch.', 1499.0, 1799.0, 'GT-MN-02', 15, 4.9, 56, 'https://images.unsplash.com/photo-1547119957-637f8679db1e?w=800&auto=format&fit=crop&q=80', 'FLAGSHIP', 'Panel: 49-inch QD-OLED Dual QHD (5120x1440) 32:9 | Curvature: 1800R | Refresh: 240Hz 0.03ms Response | Connectivity: USB-C 90W PD, HDMI 2.1, DP 1.4, KVM', 'Specialized oversized freight transport with reinforced foam cradle.', '3-Year Panel Burn-In and Zero-Dead-Pixel Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (16, 1, 'Studio Display 27" 5K Retina', 'studio-display-27-5k-retina', 'Over 14.7 million pixels of breathtaking color clarity. Boasts nano-texture anti-reflective glass, P3 wide color gamut, integrated 12MP Center Stage camera, and studio-quality 6-speaker array.', 1599.0, 1799.0, 'GT-MN-03', 22, 4.9, 110, 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&auto=format&fit=crop&q=80', 'BESTSELLER', 'Resolution: 27-inch 5K Retina (5120x2880) 218 PPI | Brightness: 600 nits P3 True Tone | Audio: 6-speaker sound system with force-cancelling woofers | Ports: 1x Thunderbolt 3 (96W), 3x USB-C', 'Dispatched in reinforced custom suspension box.', '2-Year Official Display Exchange Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (17, 1, 'Precision Trackpad Solid Glass', 'precision-trackpad-solid-glass', 'Crafted from a continuous sheet of acid-etched matte tempered glass with haptic force sensors beneath the surface. Translates gestures with zero friction and millisecond precision.', 149.0, 179.0, 'GT-KB-02', 65, 4.8, 142, 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=800&auto=format&fit=crop&q=80', 'NEW', 'Surface: Matte Acid-Etched Tempered Glass | Feedback: Dual Linear Resonant Actuators | Connectivity: Bluetooth 5.3 & USB-C Braided | Battery: 60 Days on single charge', 'Standard sealed parcel courier delivery.', '1-Year Free Hardware Replacement.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (18, 1, 'Carbon Arc Ergonomic Mouse', 'carbon-arc-ergonomic-mouse', 'Engineered to align your forearm in a completely neutral 57-degree vertical handshake position. Features an 8000 DPI Darkfield sensor that tracks seamlessly on clear glass.', 119.0, 149.0, 'GT-KB-03', 80, 4.7, 185, 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Ergonomics: 57-degree Natural Vertical Angle | Sensor: 8000 DPI Darkfield Laser | Switches: Optical-Mechanical Silent Actuators | Battery: Up to 90 Days', 'Eco-friendly protective kraft packaging.', '2-Year Switch and Scroll Wheel Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (19, 1, 'Thunderbolt 5 Dual 8K Hub', 'thunderbolt-5-dual-8k-hub', 'Harness up to 80Gbps bidirectional transfer speeds with next-generation Thunderbolt 5 protocol. Powers dual 8K 60Hz HDR displays while delivering 140W fast power delivery to your workstation.', 329.0, 379.0, 'GT-AC-01', 40, 4.9, 73, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&auto=format&fit=crop&q=80', 'NEW', 'Bandwidth: 80Gbps Bandwidth Boost to 120Gbps | Power: 140W Host Charging | Ports: 3x TB5, 1x 2.5GbE, 1x SD 4.0, 3x USB-A 10Gbps | Enclosure: Anodized Heatsink Aluminum', 'Dispatched with included 1m certified 80Gbps Thunderbolt 5 cable.', '2-Year Circuit and Controller Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (20, 1, 'Custom Braided Studio Coiled Cable', 'custom-braided-studio-coiled-cable', 'Handmade studio keyboard cable featuring double-sleeved PET flex and paracord, a heavy-duty detachable GX16 aviator connector, and CNC gold-plated USB-C ends.', 49.0, 69.0, 'GT-KB-04', 90, 4.8, 160, 'https://images.unsplash.com/photo-1595225476474-87563907a212?w=800&auto=format&fit=crop&q=80', 'SALE', 'Connector: 5-Pin Heavy-duty GX16 Metal Aviator | Length: 1.5m Total (15cm Coil + 1.2m Straight) | Sleeving: Dual-layer Paracord + Techflex | Interface: USB-C to USB-A Gold Plated', 'Ships in protective round metal tin.', 'Lifetime Craftsmanship Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (21, 2, 'FoldX Dual Horizon Foldable', 'foldx-dual-horizon-foldable', 'A triumph of mechanical miniaturization. Zero-gap titanium teardrop hinge opens to reveal an expansive 7.8-inch 120Hz LTPO OLED canvas with imperceptible crease technology and dual stylus digitizers.', 1799.0, 1999.0, 'GT-PH-02', 20, 4.9, 68, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&auto=format&fit=crop&q=80', 'FLAGSHIP', 'Internal Display: 7.82-inch Flexi-OLED 120Hz (2440x2268) | Cover: 6.31-inch FHD+ 120Hz | Processor: Snapdragon 8 Gen 3 | Camera: Hasselblad Triple 48MP/64MP/48MP', 'VIP Priority Courier with tamper-proof security seals.', '2-Year Complete Screen and Mechanical Hinge Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (22, 2, 'Neo Pixel 8 Ceramic Edition', 'neo-pixel-8-ceramic', 'Mirror-finished high-density zircon ceramic body that is virtually impervious to scratches. Features our bespoke on-device neural photography pipeline and real-time live language synthesis.', 899.0, 1049.0, 'GT-PH-03', 42, 4.8, 134, 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Material: Nanotech Microcrystalline Ceramic | Display: 6.2-inch Actua OLED 120Hz | Camera: 50MP Octa-PD Main with Macro Focus | Battery: 4575 mAh Extreme Battery Saver', 'Free domestic express shipping with insurance.', '1-Year Global Hardware Warranty with 7 years OS updates.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (23, 2, 'Titanium Ultra Prime 24', 'titanium-ultra-prime-24', 'The ultimate mobile workstation. Integrated bluetooth stylus, groundbreaking 200MP periscope zoom with 100x Space Zoom algorithms, and a reflection-free Gorilla Armor glass display.', 1299.0, 1449.0, 'GT-PH-04', 36, 4.9, 155, 'https://images.unsplash.com/photo-1580910051074-3eb694886505?w=800&auto=format&fit=crop&q=80', 'HOT', 'Chassis: Grade-2 Titanium Frame | Display: 6.8-inch Dynamic AMOLED 2X QHD+ 2600 nits | Stylus: S-Pen with 2.8ms latency | Zoom: 200MP Main + 50MP 5x Optical + 10MP 3x', 'Dispatched in secure sealed anti-theft box.', '2-Year Official Manufacturer Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (24, 2, 'Quantum Glass Minimalist Phone', 'quantum-glass-minimalist-phone', 'Transparent minimalism perfected. Features an interactive rear LED Glyph matrix that signals priority callers and charge status with zero screen addiction, wrapped in a pure bloatware-free OS.', 649.0, 749.0, 'GT-PH-05', 50, 4.7, 92, 'https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=800&auto=format&fit=crop&q=80', 'NEW', 'Design: Transparent Glass Back with 33 Glyph LED Zones | OS: Clean Vanilla Android with custom monochrome UI | Display: 6.7-inch OLED 120Hz | Charging: 45W Wired, 15W Wireless', 'Ships with transparent braided USB-C cable and pre-applied glass protector.', '2-Year Hardware Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (25, 2, 'Compact Horizon 5.9" Mini Phone', 'compact-horizon-mini-phone', 'Flagship power restored to the one-handed form factor. Packed with top-tier silicon, 6-axis hybrid gimbal stabilization, and an ergonomic textured polymer back that never slips.', 699.0, 799.0, 'GT-PH-06', 30, 4.6, 61, 'https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=800&auto=format&fit=crop&q=80', 'SALE', 'Form Factor: 5.9-inch Compact Ergonomic (169g) | Processor: Snapdragon 8 Gen 3 | Camera: 50MP Gimbal Stabilizer 2.0 | Audio: Dual stereo speakers with Dirac HD', 'Standard insured parcel dispatch.', '1-Year Limited Hardware Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (26, 2, 'Alpha Rugged Satellite Phone', 'alpha-rugged-satellite-phone', 'Engineered for extreme wilderness expeditions. MIL-STD-810H shock certification, dual-satellite SOS beacon, integrated thermal imaging sensor, and massive 10,000mAh sub-zero battery.', 849.0, 999.0, 'GT-PH-07', 16, 4.8, 38, 'https://images.unsplash.com/photo-1533228876829-65c94e7b5025?w=800&auto=format&fit=crop&q=80', 'LIMITED', 'Durability: IP68 / IP69K / MIL-STD-810H Drop-proof | Satellite: Two-way Iridium SOS Messaging | Thermal: FLIR Lepton 3.5 Core | Battery: 10,600mAh with Reverse Charging', 'Shipped in watertight Pelican-style protective container.', '2-Year Rugged Survival Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (27, 2, 'MagSafe 15W Qi2 Stand Charger', 'magsafe-15w-qi2-stand-charger', 'Sculpted from a single solid block of matte-beaded aluminum. Wirelessly fast-charges phone, smartwatch, and audio buds simultaneously with certified 15W Qi2 magnetic alignment.', 99.0, 129.0, 'GT-PH-08', 75, 4.9, 190, 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=800&auto=format&fit=crop&q=80', 'BESTSELLER', 'Compatibility: Apple MagSafe & Qi2 Universal | Output: 15W Phone + 5W Watch + 5W Buds | Material: Weighted Aircraft Aluminum with Silicone Base | Cable: 1.5m Braided USB-C included', 'Dispatched in luxury retail presentation box.', '2-Year Coil & Electronics Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (28, 2, 'Anodized Titanium Phone Case', 'anodized-titanium-phone-case', 'Precision machined from Grade 5 titanium alloy with an interior honeycomb impact-absorbent elastomer. Features a flush magnetic kickstand and lanyard tether point.', 79.0, 99.0, 'GT-PH-09', 110, 4.8, 240, 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Material: CNC Machined Grade-5 Titanium + TPU | Protection: 14ft Drop Tested Military Standard | Features: Integrated 120-degree kickstand, MagSafe magnet array', 'Standard sealed accessory airmail dispatch.', 'Lifetime Structural Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (29, 3, 'Horizon Chrono Sapphire Watch', 'horizon-chrono-sapphire-watch', 'Classic horological elegance merged with advanced biometric monitoring. Features a diamond-cut fluted bezel, sapphire crystal face, dual-lead ECG sensor, and 14-day smart battery life.', 649.0, 749.0, 'GT-WB-02', 25, 4.9, 82, 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=800&auto=format&fit=crop&q=80', 'FLAGSHIP', 'Case: 46mm 316L Stainless Steel & Ceramic | Display: 1.43-inch Sapphire AMOLED 1500 nits | Sensors: ECG, PPG, SpO2, Skin Temperature, Barometer | Battery: Up to 14 Days', 'Presented in leather-lined watch gift box with additional silicon strap.', '2-Year International Watchmaking Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (30, 3, 'Terra Adventure GPS Expedition', 'terra-adventure-gps-expedition', 'The pinnacle of mountaineering electronics. Solar-charging power sapphire glass yields up to 100 days of battery life in expedition mode, paired with multi-band GNSS sat-nav and topo maps.', 799.0, 899.0, 'GT-WB-03', 20, 4.8, 67, 'https://images.unsplash.com/photo-1544117519-31a4b719223d?w=800&auto=format&fit=crop&q=80', 'HOT', 'Lens: Power Sapphire with Solar Absorption | Bezel: DLC Titanium | Mapping: Preloaded Multi-Continent TopoActive Maps | Battery: 34 Days Smartwatch / 150 Hours GPS Solar', 'Delivered in ruggedized shockproof explorer kit.', '2-Year Global Adventure Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (31, 3, 'Oura Gen 4 Smart Health Ring', 'oura-gen4-smart-health-ring', 'Featherweight titanium smart ring that tracks your sleep stages, HRV balance, and daytime resilience with surgical accuracy directly from the arterial blood vessels in your finger.', 399.0, 449.0, 'GT-WB-04', 45, 4.9, 215, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&auto=format&fit=crop&q=80', 'BESTSELLER', 'Material: Durable Titanium with PVD Stealth Coating | Weight: 4 to 6 grams | Sensors: Infrared PPG, Skin Temp, 3D Accelerometer | Battery: Up to 8 Days with wireless dock', 'Includes complimentary Ring Sizing Kit before final ring dispatch.', '1-Year Complete Replacement Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (32, 3, 'Pulse Slim Biometric Band', 'pulse-slim-biometric-band', 'Screen-free athletic optimization. Designed to be worn 24/7 on the wrist or bicep to quantify physiological strain, recovery sleep, and cardiovascular load without distracting notifications.', 199.0, 249.0, 'GT-WB-05', 60, 4.7, 140, 'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Form: Screenless Lightweight Athletic Strap | Sensors: 5 LEDs, 4 Photodiodes, Body Temp | Waterproof: IP68 (Up to 10m) | Battery: 5 Days with on-the-go slide battery pack', 'Standard express parcel delivery.', '1-Year Performance Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (33, 3, 'Horizon Spatial AR Glasses', 'horizon-spatial-ar-glasses', 'Plug in and project a massive 201-inch virtual OLED cinema display directly in front of your eyes. Weighs only 75g with electrochromic dimming lenses and directional spatial audio temples.', 499.0, 599.0, 'GT-WB-06', 22, 4.8, 54, 'https://images.unsplash.com/photo-1593508512255-86ab42a8e620?w=800&auto=format&fit=crop&q=80', 'NEW', 'Optics: Sony Micro-OLED Dual Displays (1080p per eye) | Field of View: 46-degree FOV (Equivalent 201" at 6m) | Refresh: 120Hz | Weight: 75 grams Ultra-lightweight', 'Ships in protective molded hard case with prescription lens frame insert.', '1-Year Optical and Electronic Display Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (34, 3, 'Titan Tactical Diver Watch', 'titan-tactical-diver-watch', 'Professional EN13319 certified dive computer smartwatch rated to 200 meters. Features acoustic underwater alarms, tank pressure transmitter pairing, and automatic dive entry logging.', 899.0, 1099.0, 'GT-WB-07', 12, 4.9, 31, 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=800&auto=format&fit=crop&q=80', 'LIMITED', 'Certification: EN13319 200m Dive Standard | Dive Modes: Single/Multi-Gas, Nitrox, Trimix, Gauge, Apnea | Screen: Sunlight-visible MIP Transflective | Gas Integration: SubWave Sonar', 'Shipped in waterproof hard-shell dive briefcase.', '2-Year Pressure Vessel and Sensor Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (35, 3, 'Milanese Magnetic Titanium Loop', 'milanese-magnetic-titanium-loop', 'Woven from fine titanium mesh filaments on specialized Swiss machinery. Infinitely adjustable magnetic clasp provides a custom tailored fit that is both breathable and dress-ready.', 89.0, 119.0, 'GT-WB-08', 85, 4.8, 175, 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=800&auto=format&fit=crop&q=80', 'SALE', 'Material: Grade-2 Titanium Woven Mesh | Clasp: Dual Neodymium Magnet Array | Sizing: Universal 42mm - 49mm Lug Compatibility | Weight: 34 grams', 'Standard sealed protective sleeve dispatch.', 'Lifetime Mesh Integrity Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (36, 3, 'Aero Polarized Smart Audio Shades', 'aero-polarized-smart-audio-shades', 'Polarized UV400 lenses housed in ultra-flexible TR90 frames with wafer-thin open-ear acoustic speakers built into the temples. Enjoy calls and playlists while hearing the world around you.', 279.0, 329.0, 'GT-WB-09', 40, 4.7, 86, 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Lenses: Polarized Polycarbonate UV400 Protection | Audio: Dual 16mm Micro Transducers with Beamforming Mics | Battery: 8 Hours continuous playback | Weight: 48 grams', 'Ships with magnetic charging cable and microfiber cleaning pouch.', '1-Year Electro-Acoustic Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (37, 4, 'Planar Magnetic Reference Headphones', 'planar-magnetic-reference-headphones', 'Audiophile master reference headphones featuring ultra-thin 100mm planar magnetic diaphragms and open-back walnut resonance chambers. Delivers an expansive holographic soundstage.', 899.0, 1049.0, 'GT-AU-02', 16, 5.0, 52, 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=800&auto=format&fit=crop&q=80', 'STUDIO', 'Transducer: 106mm Planar Magnetic Diaphragm | Frequency Response: 5Hz - 50,000Hz | Impedance: 32 Ohms | Earcups: CNC Solid American Walnut with Lambskin Pads', 'Packed in velvet-lined wooden collector case with balanced 4.4mm & 6.35mm cables.', '3-Year Audiophile Transducer Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (38, 4, 'QuietComfort Studio ANC', 'quietcomfort-studio-anc', 'Whisper-quiet acoustic silence. Features an 8-microphone hybrid noise cancellation array, proprietary CustomTune personalization, and up to 30 hours of continuous high-fidelity listening.', 399.0, 449.0, 'GT-AU-03', 45, 4.9, 168, 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=800&auto=format&fit=crop&q=80', 'BESTSELLER', 'ANC: 8-Microphone Active Noise Cancellation Array | Codecs: LDAC, aptX Adaptive, AAC | Battery: 30 Hours with ANC active (15 min charge = 3 hours) | Comfort: Plush protein leather', 'Includes slim hard-shell travel case and airline adapter.', '2-Year Complete Electrical & Driver Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (39, 4, 'TrueSound Pro Wireless Earbuds', 'truesound-pro-wireless-earbuds', 'Studio performance in your pocket. Coaxial dual-driver architecture with a dynamic 11mm bass woofer and Knowles balanced armature tweeter. Lossless audio broadcast case doubles as audio transmitter.', 249.0, 299.0, 'GT-AU-04', 70, 4.8, 210, 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800&auto=format&fit=crop&q=80', 'HOT', 'Acoustics: 11mm Dynamic Driver + Balanced Armature | Smart Case: Wireless Audio Retransmit via 3.5mm/USB-C | Battery: 9 Hours (36h with case) | Water: IP57 Sweatproof', 'Shipped in sealed retail box with 5 sizes of oval silicone tips.', '1-Year Earbud Exchange Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (40, 4, 'Sonic Active Sport Earbuds', 'sonic-active-sport-earbuds', 'Engineered for marathoners and intense workouts. Moldable memory-wire ear hooks ensure an unshakeable seal, rated IP68 waterproof and washable under running tap water.', 179.0, 219.0, 'GT-AU-05', 55, 4.7, 130, 'https://images.unsplash.com/photo-1572536147248-ac59a8abfa4b?w=800&auto=format&fit=crop&q=80', 'SALE', 'Protection: IP68 Fully Waterproof & Dustproof | Fit: Secure Flexible Ear-Hook System | Battery: 12 Hours per charge | Mics: Wind-blocking bone conduction sensors', 'Standard fast courier delivery.', '2-Year Sweat and Water Ingress Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (41, 4, 'Audiophile Desktop DAC Amplifier', 'audiophile-desktop-dac-amplifier', 'High-resolution desktop digital-to-analog converter equipped with dual ESS Sabre ES9038Q2M chips and balanced THX AAA amplification. Drives demanding studio monitors and high-impedance headphones with zero noise floor.', 449.0, 529.0, 'GT-AU-06', 22, 4.9, 48, 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=800&auto=format&fit=crop&q=80', 'STUDIO', 'DAC Chips: Dual ESS Sabre ES9038Q2M | Decoding: PCM 768kHz/32-bit & DSD512 Native | Outputs: 4.4mm Balanced, 6.35mm Single-ended, RCA Pre-out | SNR: 125dB Ultra-clean', 'Ships in custom heavy-duty cardboard sleeve with shielded gold-plated USB-C cable.', '2-Year High-Fidelity Audio Board Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (42, 4, 'Studio Monitor Desktop Pair', 'studio-monitor-desktop-pair', 'Nearfield professional studio monitors with woven composite 5.25-inch woofers, 1-inch silk dome tweeters, and acoustic room tuning switches. Delivers honest, uncolored sonic accuracy.', 599.0, 699.0, 'GT-AU-07', 18, 4.8, 64, 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Power: 140W Bi-Amplified Class-D | Frequency Response: 45Hz - 22,000Hz | Inputs: Balanced XLR, 1/4" TRS, Unbalanced RCA | Cabinet: Vinyl-laminated MDF with acoustic damping', 'Ships as matched pair in reinforced twin packaging with isolation foam pads.', '3-Year Studio Transducer Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (43, 4, 'Dolby Atmos Spatial Soundbar', 'dolby-atmos-spatial-soundbar', 'True 7.1.4 spatial audio without rear speaker clutter. 11 discrete precision drivers including dual up-firing height channels reflect audio off ceilings to immerse you in cinema-grade sound.', 799.0, 949.0, 'GT-AU-08', 20, 4.9, 78, 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=800&auto=format&fit=crop&q=80', 'FLAGSHIP', 'Channels: 7.1.4 Spatial Atmos Acoustic Array | Output: 500W Total Peak Power | Connectivity: eARC HDMI 2.1, AirPlay 2, Spotify Connect, Optical | Calibration: Automated Room Sensing', 'Oversized protective freight dispatch.', '2-Year Amplifier and Subwoofer Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (44, 4, 'Solid Walnut Headphone Stand', 'solid-walnut-headphone-stand', 'Minimalist desktop headphone perch crafted from sustainably harvested solid black walnut wood and matte-black sandblasted weighted aluminum. Prevents headband indentation.', 79.0, 99.0, 'GT-AU-09', 95, 4.9, 210, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format&fit=crop&q=80', 'SALE', 'Material: 100% Solid Natural Black Walnut + Heavy Cast Aluminum | Base: Anti-slip silicone ring | Height: 28cm fits all standard over-ear cans | Finish: Natural beeswax polish', 'Eco-friendly gift packaging.', 'Lifetime Wood and Structure Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (45, 5, 'Phantom Scout Mini 4K (249g)', 'phantom-scout-mini-4k', 'Exempt from FAA registration under the 249-gram threshold. Boasts true 4K/60fps HDR video, 3-axis mechanical gimbal stabilization, 38 minutes of battery life, and level-5 wind resistance.', 499.0, 599.0, 'GT-DR-02', 28, 4.8, 114, 'https://images.unsplash.com/photo-1527977966376-1c8408f9f108?w=800&auto=format&fit=crop&q=80', 'BESTSELLER', 'Weight: 249 grams Ultra-light Foldable | Camera: 1/1.3" CMOS 48MP 4K/60fps HDR | Flight Time: 38 Minutes | Transmission: 10km HD Video Range', 'Dispatched with shoulder bag and 2 spare propellers.', '1-Year Free Crash Replacement Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (46, 5, 'CineFalcon 8K Cinema Drone', 'cinefalcon-8k-cinema-drone', 'The ultimate Hollywood aerial platform. Features a full-frame 8K sensor, Apple ProRes RAW internal recording, hot-swappable dual flight batteries, and dual-operator master-slave controller links.', 3499.0, 3999.0, 'GT-DR-03', 8, 5.0, 22, 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=800&auto=format&fit=crop&q=80', 'STUDIO', 'Camera: Full-Frame 8K/75fps Apple ProRes RAW & CinemaDNG | Speed: 94 km/h in Sport Mode | Sensors: 360-degree LiDAR Omnidirectional Avoidance | Flight: 28 min per dual pack', 'Shipped in industrial airtight IP67 rolling flight case.', '2-Year Enterprise Drone Care with on-demand motor replacement.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (47, 5, 'Apex FPV Racing Quadcopter', 'apex-fpv-racing-quadcopter', 'Pure adrenaline at 140 km/h. Built on a 5mm 3K carbon-fiber unibody frame with brushless 2207 motors, digital HD low-latency video transmitter, and included high-refresh FPV goggles.', 649.0, 749.0, 'GT-DR-04', 18, 4.9, 45, 'https://images.unsplash.com/photo-1524143986875-3b098d78b363?w=800&auto=format&fit=crop&q=80', 'HOT', 'Frame: 5mm Chamfered 3K Carbon Fiber | Top Speed: 140 km/h (0-100 in 1.8s) | Video: DJI O3 Air Unit Digital HD | Controls: ELRS 2.4GHz Ultra-low Latency', 'Includes digital FPV OLED goggles, remote controller, and 4x LiPo batteries.', '1-Year Electronic Flight Controller Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (48, 5, 'SkyEye Thermal Search Drone', 'skyeye-thermal-search-drone', 'Industrial search-and-rescue aerial unit featuring dual radiometric thermal (640x512) and 48MP zoom lenses, 1200m laser rangefinder, and IP55 weather-sealed carbon airframe.', 2899.0, 3299.0, 'GT-DR-05', 10, 4.8, 19, 'https://images.unsplash.com/photo-1507582020432-2a3bc418123f?w=800&auto=format&fit=crop&q=80', 'LIMITED', 'Thermal: 640x512 @ 30Hz Radiometric Sensor | Visual: 48MP with 56x Hybrid Zoom | Weather: IP55 Rain & Snow Rated (-20C to 50C) | Flight: 45 min per battery', 'Dispatched in reinforced waterproof Pelican transport crate.', '3-Year Industrial Mission Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (49, 5, 'Orbit 360 Handheld 3-Axis Gimbal', 'orbit-360-handheld-gimbal', 'Cinematic stabilizer for smartphones and mirrorless cameras. High-torque brushless motors eliminate micro-shakes, paired with a built-in magnetic fill light and AI face tracking sensor.', 299.0, 349.0, 'GT-DR-06', 45, 4.7, 85, 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Payload: Supports up to 1.2kg payload | Stabilization: 7th Gen 3-Axis Orthogonal Algorithm | Features: Magnetic AI Tracking Module, Extension Rod, OLED Display | Battery: 12 Hours', 'Standard sealed accessory box with mini tripod.', '1-Year Motor & Gimbal Stabilization Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (50, 5, 'Veloce Pocket Selfie Drone', 'veloce-pocket-selfie-drone', 'Takes off and lands directly on your palm. Fully enclosed propeller cages make it safe around children and crowds, while automated AI flight paths capture cinema selfies at the touch of a button.', 299.0, 359.0, 'GT-DR-07', 35, 4.6, 68, 'https://images.unsplash.com/photo-1527977966376-1c8408f9f108?w=800&auto=format&fit=crop&q=80', 'SALE', 'Safety: Enclosed AeroPropeller Guards | Takeoff: One-touch Palm Launch & Return | Camera: 4K Ultra-wide stabilized video | Flight: 16 min (Includes 3x batteries + charging dock)', 'Ships in compact travel pouch with multi-battery charger.', '1-Year Free Hardware Replacement.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (51, 5, 'Intelligent Flight Battery Multi-Hub', 'intelligent-flight-battery-hub', 'Rapid 100W parallel charging station for up to four intelligent drone batteries. Features an integrated OLED status display, internal active fan cooling, and emergency power-bank discharge mode.', 129.0, 159.0, 'GT-DR-08', 60, 4.8, 120, 'https://images.unsplash.com/photo-1507582020432-2a3bc418123f?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Power: 100W PD Ultra-fast Charging | Slots: 4 Smart Battery Slots with Sequential/Parallel Switching | Display: Real-time Voltage & Health Status OLED | Material: Flame-retardant Polycarbonate', 'Standard express parcel delivery.', '2-Year Electrical Circuit Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (52, 6, 'Minimalist Glass Smart Thermostat', 'minimalist-glass-smart-thermostat', 'A circular jewel of black curved glass on your wall. Uses millimeter-wave radar to sense room occupancy, balancing indoor air temperature and cutting HVAC energy costs by up to 26%.', 249.0, 299.0, 'GT-SH-02', 40, 4.9, 145, 'https://images.unsplash.com/photo-1558002038-1055907df827?w=800&auto=format&fit=crop&q=80', 'BESTSELLER', 'Display: High-contrast Circular AMOLED Glass Display | Connectivity: Matter over Thread, Wi-Fi, Zigbee | Sensors: Radar Occupancy, Humidity, Ambient Light, VOC | Savings: 26% Certified Energy Star', 'Includes magnetic trim wall plate and precision screwdriver.', '3-Year HVAC Controller Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (53, 6, 'Ambient Modular OLED Wall Kit', 'ambient-modular-oled-wall-kit', 'Architectural modular light panels with zero hot spots. Mounts effortlessly with damage-free adhesive strips, synchronizing with PC monitors and audio frequencies in real-time.', 329.0, 399.0, 'GT-SH-03', 35, 4.8, 110, 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&auto=format&fit=crop&q=80', 'HOT', 'Panels: 9x Hexagonal Modular Diffused Panels | Colors: 16.8 Million Colors + Pure Tunable White (1200K - 6500K) | Sync: Razer Chroma, Apple HomeKit, PC Screen Mirror | Power: 42W Supply included', 'Ships in protective compartmentalized organizer box.', '2-Year LED Module Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (54, 6, 'Ultra-Quiet HEPA H13 Air Purifier', 'ultra-quiet-hepa-air-purifier', 'Medical-grade H13 true HEPA filtration that traps 99.97% of airborne pollutants down to 0.1 microns. Whispers at an inaudible 18dB in night mode with live laser PM2.5 air quality readout.', 399.0, 479.0, 'GT-SH-04', 25, 4.9, 98, 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Filtration: 4-Stage True HEPA H13 + Granular Activated Carbon | Coverage: Cleans 1200 sq ft room in 30 minutes | Noise Level: 18dB Whisper Quiet | Sensors: Infrared PM2.5 Laser Particle Counter', 'Heavy freight delivery with initial 1-year replacement filter included.', '3-Year Motor and Fan Guarantee.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (55, 6, 'Horizon Motorized Ergonomic Desk', 'horizon-motorized-ergonomic-desk', 'Solid 1.5-inch sustainably harvested bamboo desktop resting on dual-motor three-stage steel columns. Operates under 45dB with anti-collision gyro sensors and 4 programmable memory heights.', 899.0, 1099.0, 'GT-SH-05', 15, 4.9, 62, 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=800&auto=format&fit=crop&q=80', 'FLAGSHIP', 'Top: 60" x 30" Solid Natural Bamboo | Lifting Mechanism: Dual German-Engineered Motors | Height Range: 24.5" to 50.2" | Weight Capacity: 355 lbs | Features: Cable Management Tray & 65W USB-C', 'Palletized heavy courier delivery directly to your room of choice.', '10-Year Frame and Motor Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (56, 6, 'RoboClean Pro Vacuum & Mop', 'roboclean-pro-vacuum-mop', 'Zero maintenance cleaning. 8,000Pa extreme cyclone suction with dual rotating pressurized mop heads that automatically wash with 60C hot water and dry with heated air at the all-in-one dock.', 799.0, 949.0, 'GT-SH-06', 22, 4.8, 89, 'https://images.unsplash.com/photo-1563178406-4cdc2923acbc?w=800&auto=format&fit=crop&q=80', 'BESTSELLER', 'Suction: 8000Pa Vormax Suction | Mopping: Dual High-speed Rotary Pressurized Mop | Base Station: Auto Dust Empty (75 Days), Hot Water Mop Wash & 45C Hot Air Dry | Nav: 3D Structured Light LiDAR', 'Ships in protective heavy-duty corrugated shipping box.', '2-Year Complete Robotic Appliance Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (57, 6, '4K HDR Laser Cinema Projector', '4k-hdr-laser-cinema-projector', 'Transform any blank wall into a 120-inch cinema canvas from just 10 inches away. Delivers 3,000 ANSI lumens of ALPD 4.0 triple-laser brightness with integrated 60W Harman Kardon sound.', 1899.0, 2199.0, 'GT-SH-07', 12, 5.0, 36, 'https://images.unsplash.com/photo-1593784991095-a205069470b6?w=800&auto=format&fit=crop&q=80', 'STUDIO', 'Technology: Ultra-Short Throw ALPD 4.0 Triple Laser | Resolution: True 4K UHD with HDR10+ & Dolby Vision | Brightness: 3000 ANSI Lumens | Audio: 60W Harman Kardon with Dolby Audio', 'Insured freight courier delivery with velvet lens cover.', '3-Year Laser Engine and Projector Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (58, 6, 'Biometric Smart Deadbolt Lock', 'biometric-smart-deadbolt-lock', 'Unlock your front door in 0.3 seconds with 3D biometric fingerprint recognition, Apple Home Key tap from your iPhone or Apple Watch, or encrypted PIN codes on the sleek backlit keypad.', 229.0, 279.0, 'GT-SH-08', 48, 4.8, 120, 'https://images.unsplash.com/photo-1558002038-1055907df827?w=800&auto=format&fit=crop&q=80', 'POPULAR', 'Authentication: 3D Fingerprint (0.3s), Apple Home Key NFC, Backlit Keypad, Emergency Mechanical Key | Rating: BHMA Commercial Grade 2 Security | Battery: 12 Months on 8x AA', 'Standard sealed accessory box with all installation hardware.', '3-Year Mechanical and Finish Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (59, 6, '4K Solar Outdoor Security Cam', '4k-solar-outdoor-security-cam', 'Completely wire-free home surveillance. An integrated solar panel provides continuous power, paired with 360-degree pan-tilt coverage, starlight full-color night vision, and on-device BionicMind AI.', 249.0, 299.0, 'GT-SH-09', 55, 4.8, 165, 'https://images.unsplash.com/photo-1557597774-9d273605dfa9?w=800&auto=format&fit=crop&q=80', 'HOT', 'Resolution: 4K UHD (3840x2160) with 360 Pan-Tilt | Power: Integrated Monocrystalline Solar Panel (2 Hours sun/day for infinite battery) | Storage: Up to 16TB local storage with Zero Monthly Fees', 'Ships with mounting bracket, screw anchors, and drilling template.', '2-Year Weatherproof Outdoor Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO products (id, category_id, name, slug, description, price, original_price, sku, stock_quantity, rating, reviews_count, main_image, badge, tech_specs, shipping_info, warranty_info) 
VALUES (60, 6, 'Nordic Wireless Charging Valet Tray', 'nordic-wireless-charging-valet-tray', 'Crafted from vegetable-tanned full-grain Tuscan leather and weighted solid brass. Houses dual fast-charging Qi wireless coils alongside a sculpted catchall tray for your keys, glasses, and pens.', 129.0, 159.0, 'GT-SH-10', 70, 4.9, 188, 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=800&auto=format&fit=crop&q=80', 'SALE', 'Leather: Full-Grain Italian Tuscan Leather | Coils: Dual 10W / 15W High-Efficiency Wireless Coils | Base: Non-slip Weighted Brushed Brass | Dimensions: 11" x 8" x 0.75"', 'Delivered in linen presentation gift pouch.', 'Lifetime Leather Craftsmanship Warranty.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), stock_quantity=VALUES(stock_quantity);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (9, 'RAM', '16GB Unified Memory', 0.0, 1);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (9, 'RAM', '24GB Unified Memory', 200.0, 0);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (9, 'STORAGE', '512GB High-Speed SSD', 0.0, 1);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (9, 'STORAGE', '1TB High-Speed SSD', 200.0, 0);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (9, 'STORAGE', '2TB High-Speed SSD', 600.0, 0);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (10, 'RAM', '36GB Unified Memory', 0.0, 1);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (10, 'RAM', '48GB Unified Memory', 300.0, 0);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (10, 'RAM', '96GB Unified Memory', 800.0, 0);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (10, 'STORAGE', '1TB NVMe Gen4', 0.0, 1);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (10, 'STORAGE', '2TB NVMe Gen4', 400.0, 0);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (10, 'STORAGE', '4TB NVMe Gen4', 1000.0, 0);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (21, 'STORAGE', '512GB UFS 4.0', 0.0, 1);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (21, 'STORAGE', '1TB UFS 4.0', 250.0, 0);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (23, 'STORAGE', '256GB NVMe', 0.0, 1);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (23, 'STORAGE', '512GB NVMe', 150.0, 0);
INSERT INTO product_variants (product_id, variant_type, variant_value, price_delta, is_default)
VALUES (23, 'STORAGE', '1TB NVMe', 350.0, 0);