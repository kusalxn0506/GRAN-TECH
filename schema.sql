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
    order_status ENUM('PROCESSING', 'FULFILLED', 'CANCELLED') DEFAULT 'PROCESSING',
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
