class ConstantmodificationTest
    ProcessReminderJob

    # regular accessor
    def test_regular_accessor
        ProcessReminderJob.some_attribute = "something" # $ Alert
    end

    # mutable one
    def test_mutable_accessor
        ProcessReminderJob.some_array << "value" # $ Alert
    end

    def test_hash_accessor
        ProcessReminderJob.some_hash[:key] = "value" # $ Alert
    end
end