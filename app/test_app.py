from app import generate_event


def test_event_contains_required_fields():
    event = generate_event()

    assert "timestamp" in event
    assert "application" in event
    assert "environment" in event
    assert "level" in event
    assert "status" in event
    assert "message" in event
    assert "response_time_ms" in event


def test_application_name():
    event = generate_event()

    assert event["application"] == "demo-api"


def test_environment():
    event = generate_event()

    assert event["environment"] == "dev"


def test_response_time_is_positive():
    event = generate_event()

    assert event["response_time_ms"] > 0