from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Конфигурация базы данных
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://username:password@localhost/housing_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Модели таблиц
class House(db.Model):
    tablename = 'houses'
    house_id = db.Column(db.Integer, primary_key=True)
    address = db.Column(db.String(255), nullable=False)
    year_built = db.Column(db.Integer, nullable=False)
    floors = db.Column(db.Integer, nullable=False)

class Apartment(db.Model):
    tablename = 'apartments'
    apartment_id = db.Column(db.Integer, primary_key=True)
    house_id = db.Column(db.Integer, db.ForeignKey('houses.house_id', ondelete='CASCADE'), nullable=False)
    apartment_number = db.Column(db.Integer, nullable=False)
    floor = db.Column(db.Integer, nullable=False)
    total_area = db.Column(db.Numeric(10, 2), nullable=False)

class Resident(db.Model):
    tablename = 'residents'
    resident_id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(255), nullable=False, unique=True)
    birth_date = db.Column(db.Date, nullable=False)
    social_status = db.Column(db.String(100), nullable=False)
    house_id = db.Column(db.Integer, db.ForeignKey('houses.house_id', ondelete='CASCADE'), nullable=False)
    apartment_number = db.Column(db.Integer, nullable=False)

class Payment(db.Model):
    tablename = 'payments'
    payment_id = db.Column(db.Integer, primary_key=True)
    house_id = db.Column(db.Integer, db.ForeignKey('houses.house_id', ondelete='CASCADE'), nullable=False)
    apartment_number = db.Column(db.Integer, nullable=False)
    payment_date = db.Column(db.Date, nullable=False)
    amount = db.Column(db.Numeric(10, 2), nullable=False)

class Benefit(db.Model):
    tablename = 'benefits'
    benefit_id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(255), db.ForeignKey('residents.full_name', ondelete='CASCADE'), nullable=False, unique=True)
    benefit_type = db.Column(db.String(100), nullable=False)
    discount_percentage = db.Column(db.Numeric(5, 2), nullable=False)
    notes = db.Column(db.Text)

# Маршруты для работы с таблицами
@app.route('/houses', methods=['POST'])
def add_house():
    data = request.json
    new_house = House(
        address=data['address'],
        year_built=data['year_built'],
        floors=data['floors']
    )
    db.session.add(new_house)
    db.session.commit()
    return jsonify({"message": "House added successfully!"}), 201

@app.route('/houses', methods=['GET'])
def get_houses():
    houses = House.query.all()
    return jsonify([{
        "house_id": house.house_id,
        "address": house.address,
        "year_built": house.year_built,
        "floors": house.floors
    } for house in houses])

@app.route('/apartments', methods=['POST'])
def add_apartment():
    data = request.json
    new_apartment = Apartment(
        house_id=data['house_id'],
        apartment_number=data['apartment_number'],
        floor=data['floor'],
        total_area=data['total_area']
    )
    db.session.add(new_apartment)
    db.session.commit()
    return jsonify({"message": "Apartment added successfully!"}), 201

@app.route('/residents', methods=['POST'])
def add_resident():
    data = request.json
    new_resident = Resident(
        full_name=data['full_name'],
        birth_date=data['birth_date'],
        social_status=data['social_status'],
        house_id=data['house_id'],
        apartment_number=data['apartment_number']
    )
    db.session.add(new_resident)
    db.session.commit()
    return jsonify({"message": "Resident added successfully!"}), 201

@app.route('/payments', methods=['POST'])
def add_payment():
    data = request.json
    new_payment = Payment(
        house_id=data['house_id'],
        apartment_number=data['apartment_number'],
        payment_date=data['payment_date'],
        amount=data['amount']
    )
    db.session.add(new_payment)
    db.session.commit()
    return jsonify({"message": "Payment added successfully!"}), 201

@app.route('/benefits', methods=['POST'])
def add_benefit():
    data = request.json
    new_benefit = Benefit(
        full_name=data['full_name'],
        benefit_type=data['benefit_type'],
        discount_percentage=data['discount_percentage'],
        notes=data.get('notes')
    )
    db.session.add(new_benefit)
    db.session.commit()
    return jsonify({"message": "Benefit added successfully!"}), 201

# Запуск приложения
if name == '__main__':
    db.create_all()
    app.run(debug=True)
