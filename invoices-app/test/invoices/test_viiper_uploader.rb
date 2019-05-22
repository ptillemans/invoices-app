require 'test_helper'
require 'fileutils'

class TestViiperUploader < ActiveSupport::TestCase

  def setup
    @dest_dir = "/tmp/test_upload"
    FileUtils.rm_rf(@dest_dir)
    FileUtils.mkdir_p(@dest_dir)
    InvoiceConfig.set('VIIPER_RSYNC_PREFIX', '')

    @mockviiper = MiniTest::Mock.new()

    @mock_uploader = ViiperUploader.new(dest_dir: @dest_dir,
                                        rsync_prefix: "/tmp/test_upload/",
                                          oracle: @mockviiper)

    Organization.delete_all
    @organization = Organization.create(name: 'TestOrg',
                                        default_approver: 'tbb',
                                        backends: ['viiper'],
                                        viiper_dir_name: 'DIR_TESTORG')

    Invoice.delete_all
    @invoice = Invoice.new(organization: @organization,
                           book_number: '12345678',
                           file_name: 'sample/12345678.pdf',
                           uploaded: false)

  end

  def test_mock_uploader
    @mockviiper.expect(:exec,[], args=[ViiperUploader::MAX_IMPORT_ID_FOR_FILE,'12345678.pdf', 'DIR_TESTORG'])
    @mockviiper.expect(:exec,[]) do |q, dirname, &blk|
      assert_equal ViiperUploader::PATH_FOR_DIR_NAME, q
      assert_equal dirname, 'DIR_TESTORG'
      blk.call(["#{@dest_dir}/TestOrg"])
    end
    @mockviiper.expect(:exec,[],args=[ViiperUploader::IMPORT_FILE, '12345678.pdf', 106, 'DIR_TESTORG'])

    @mock_uploader.upload_invoice(@invoice)
    tgt_file = @dest_dir + '/TestOrg/12345678.pdf'
    assert File.exist?(tgt_file), "expected scan file #{tgt_file} in target folder"
    assert @mockviiper.verify, "different parameters expected in exec"
  end

  def test_max_id
    @mockviiper.expect(:exec,[]) do |q, &blk|
      assert_equal ViiperUploader::MAX_IMPORT_ID,q
      blk.call([123])
    end
    id = @mock_uploader.max_apex_import_id()
    assert_equal 123, id
  end

  def test_max_id_for_file
    testfile = '12345678.pdf'
    @mockviiper.expect(:exec,[]) do |q, f, d, &blk|
      assert_equal ViiperUploader::MAX_IMPORT_ID_FOR_FILE, q
      assert_equal testfile, f
      assert_equal 'DIR_TESTORG', d
      blk.call([23])
    end

    id = @mock_uploader.invoice_apex_id(@invoice)
    assert_equal 23, id
    assert @mockviiper.verify, "Error in db.exec parameters"
  end

end
