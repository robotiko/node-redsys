chai = require 'chai'
sinon = require 'sinon'
sinon_chai = require 'sinon-chai'

chai.use sinon_chai

should = chai.should()

Redsys = require('../src/redsys').Redsys

describe "Redsys API", ->

  before ->
    @redsys = new Redsys
      test: true
      merchant:
        code: '201920191'
        secret: 'h2u282kMks01923kmqpo'
      urls: {}

  describe "Setup", ->

    it "should point to test environment when test mode enabled", ->
      @redsys.form_url.should.equal "https://sis-t.redsys.es:25443/sis/realizarPago"

    it "should point to real environment when test mode disabled", ->
      redsys = new Redsys
      redsys.form_url.should.equal "https://sis.redsys.es/sis/realizarPago"

  describe "Sign", ->
    
    it "build payload correctly", ->
      @redsys.build_payload
        total: 1235
        order: '29292929'
        currency: 978
      .should.equal '123529292929201920191978h2u282kMks01923kmqpo'

    it "should sign correctly", ->
      data = @redsys.build_payload
        total: 1235
        order: '29292929'
        currency: 978

      @redsys.sign(data).should.equal 'c8392b7874e2994c74fa8bea3e2dff38f3913c46'

    it "should sign an order correctly", ->
      form = @redsys.create_payment
        total: 12.35
        order: '29292929'
        currency: 'EUR'
      form['Ds_Merchant_MerchantSignature'].should.equal 'c8392b7874e2994c74fa8bea3e2dff38f3913c46'


  describe "Response validation", ->

    it "should validate a response", ->
      response_data =
        Ds_Date: '24/02/2014'
        Ds_Hour: '14:05'
        Ds_SecurePayment: '1'
        Ds_Card_Country: '724'
        Ds_Amount: '73300'
        Ds_Currency: '978'
        Ds_Order: '1160HH140224'
        Ds_MerchantCode: 'xxxxxxxxx'
        Ds_Terminal: '001'
        Ds_Signature: '6eb213c8b2a259b22468f2a22fe3579e9dd0f71b'
        Ds_Response: '0000'
        Ds_MerchantData: ''
        Ds_TransactionType: '0'
        Ds_ConsumerLanguage: '1'
        Ds_AuthorisationCode: '404701'
      
      @redsys.config.merchant =
        secret: "qwertyasdf0123456789"

      @redsys.validate_response(response_data).should.be.true


